require 'spec_helper'
require 'shared_examples/web_services'

describe Assist::WebServices::OrderStatus do
  before do
    stub_request(:post, /.*orderstate\/orderstate.cfm/)
      .with(body: hash_including(ordernumber: "ok"))
        .to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "order_status_ok.xml"))
        )

    stub_request(:post, /.*orderstate\/orderstate.cfm/)
      .with(body: hash_including(ordernumber: "error"))
        .to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "order_status_error.xml"))
        )

    stub_request(:post, /.*orderstate\/orderstate.cfm/)
      .with(body: hash_including(ordernumber: "bad"))
        .to_return(status: 500, body: nil)

    stub_request(:post, /.*orderstate\/orderstate.cfm/)
      .with(body: hash_including(ordernumber: "wrong_checkvalue"))
        .to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "order_status_wrong_checkvalue.xml"))
        )
  end

  before(:each) { set_config }
  after(:each) { clear_config }

  describe "#result" do
    context "when successful response" do
      subject { Assist::WebServices::OrderStatus.new("ok") }

      it "should contain order status" do
        expect(subject.result.last[:orderstate]).to eq "Canceled"
      end

      it "should contain order billnumber" do
        expect(subject.result.last[:billnumber]).to eq "5775486650107611"
      end

      it "should contain order id" do
        expect(subject.result.last[:ordernumber].to_i).to eq 100
      end

      it "should contain checkvalue" do
        expect(subject.result.last[:checkvalue]).to eq "74DEB154081757F1E8097DDFAC35FC5C"
      end
    end

    it_behaves_like "web service bad response", Assist::WebServices::OrderStatus
    it_behaves_like "response with checkvalue"
  end

  describe "#status" do
    context "when successful response" do
      subject { Assist::WebServices::OrderStatus.new("ok") }

      it "should return order status" do
        expect(subject.status).to eq "Canceled"
      end
    end

    it_behaves_like "web service bad response", Assist::WebServices::OrderStatus
    it_behaves_like "response with checkvalue"
  end

  describe "#billnumber" do
    context "when successful response" do
      subject { Assist::WebServices::OrderStatus.new("ok") }

      it "should contain order billnumber" do
        expect(subject.billnumber).to eq "5775486650107611"
      end
    end

    it_behaves_like "web service bad response", Assist::WebServices::OrderStatus
    it_behaves_like "response with checkvalue"
  end

  describe "#original_response" do
    it_behaves_like "web service original response", Assist::WebServices::OrderStatus
  end

  it_behaves_like "api request with extra parameters", Assist::WebServices::OrderStatus
end
