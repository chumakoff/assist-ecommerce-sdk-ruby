require 'spec_helper'
require 'shared_examples/web_services'

describe Assist::WebServices::OrderStatus do
  before { set_config }
  after { clear_config }

  let(:extra_params) do
    {"startyear" => "2016", "StartMonth" => "09", startday: "03",
     :StartHour => "01", not_permitted: "1"}
  end

  describe "#request_params" do
    let(:mandatory_params) { {ordernumber: 100} }

    let(:params) do
      mandatory_params.values << extra_params
    end

    subject { Assist::WebServices::OrderStatus.new(*params).request_params }

    it_behaves_like "correct params set"
  end

  describe "#result" do
    before { stub_order_status_requests }

    context "when successful response" do
      subject { Assist::WebServices::OrderStatus.new("ok", extra_params) }

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
    before { stub_order_status_requests }

    context "when successful response" do
      subject { Assist::WebServices::OrderStatus.new("ok", extra_params) }

      it "should return order status" do
        expect(subject.status).to eq "Canceled"
      end
    end

    it_behaves_like "web service bad response", Assist::WebServices::OrderStatus
    it_behaves_like "response with checkvalue"
  end

  describe "#billnumber" do
    before { stub_order_status_requests }

    context "when successful response" do
      subject { Assist::WebServices::OrderStatus.new("ok", extra_params) }

      it "should contain order billnumber" do
        expect(subject.billnumber).to eq "5775486650107611"
      end
    end

    it_behaves_like "web service bad response", Assist::WebServices::OrderStatus
    it_behaves_like "response with checkvalue"
  end

  describe "#original_response" do
    before { stub_order_status_requests }

    it_behaves_like "web service original response", Assist::WebServices::OrderStatus
  end
end
