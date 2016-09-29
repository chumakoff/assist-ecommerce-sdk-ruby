require 'spec_helper'
require 'shared_examples/web_services'

describe Assist::WebServices::CancelOrder do
  before do
    stub_request(:post, /.*cancel\/cancel.cfm/)
      .with(body: hash_including(billnumber: "ok"))
        .to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "cancel_order_ok.xml"))
        )

    stub_request(:post, /.*cancel\/cancel.cfm/)
      .with(body: hash_including(billnumber: "error"))
        .to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "cancel_order_error.xml"))
        )

    stub_request(:post, /.*cancel\/cancel.cfm/)
      .with(body: hash_including(billnumber: "bad"))
        .to_return(status: 500, body: nil)
  end

  before(:each) { set_config }
  after(:each) { clear_config }

  describe "#result" do
    context "when successful response" do
      subject { Assist::WebServices::CancelOrder.new("ok") }

      it "should contain order status" do
        expect(subject.result[:orderstate]).to eq "Canceled"
      end

      it "should contain order billnumber" do
        expect(subject.result[:billnumber]).to eq "5775486650107611"
      end

      it "should contain order id" do
        expect(subject.result[:ordernumber].to_i).to eq 100
      end
    end

    it_behaves_like "web service bad response", Assist::WebServices::CancelOrder
  end

  describe "#original_response" do
    it_behaves_like "web service original response", Assist::WebServices::CancelOrder
  end

  it_behaves_like "api request with extra parameters", Assist::WebServices::CancelOrder
end