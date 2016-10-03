require 'spec_helper'
require 'shared_examples/web_services'

describe Assist::WebServices::ConfirmOrder do
  before { set_config }
  after { clear_config }

  let(:extra_params) do
    {"ClientIP" => "0.0.0.0", :language => "RU", not_permitted: "1"}
  end

  describe "#request_params" do
    let(:mandatory_params) { {billnumber: "1234567890"} }

    let(:params) do
      mandatory_params.values << extra_params
    end

    subject { Assist::WebServices::ConfirmOrder.new(*params).request_params }

    it_behaves_like "correct params set"
  end

  describe "#result" do
    before { stub_confirm_order_requests }

    context "when successful response" do
      subject { Assist::WebServices::ConfirmOrder.new("ok", extra_params) }

      it "should contain order status" do
        expect(subject.result[:orderstate]).to eq "Approved"
      end

      it "should contain order billnumber" do
        expect(subject.result[:billnumber]).to eq "511111100000001.2"
      end

      it "should contain order id" do
        expect(subject.result[:ordernumber].to_i).to eq 100
      end
    end

    it_behaves_like "web service bad response", Assist::WebServices::ConfirmOrder
  end

  describe "#original_response" do
    before { stub_confirm_order_requests }

    it_behaves_like "web service original response", Assist::WebServices::ConfirmOrder
  end
end