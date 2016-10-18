require 'spec_helper'

describe Assist do
  it "has a version number" do
    expect(Assist::VERSION).not_to be nil
  end

  describe "api methods" do
    before { set_config }
    after { clear_config }

    describe ".payment_url" do
      subject { Assist.payment_url(123, 100) }

      it "shoud return payment url" do
        expect(subject).to eq Assist::PaymentInterface.new(123, 100).url
      end
    end

    describe ".order_status" do
      before do
        stub_request(:post, /.*orderstate\/orderstate.cfm/).to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "order_status_ok.xml"))
        )
      end

      subject { Assist.order_status(123) }

      it "shoud return OrderStatus instance" do
        expect(subject).to be_a Assist::WebServices::OrderStatus
      end

      it "shoud contain passed parameter" do
        expect(subject.request_params[:ordernumber].to_s).to eq "123"
      end

      it "should have been performed" do
        expect(subject.instance_variable_get("@response")).to be
      end
    end

    describe ".cancel_order" do
      before do
        stub_request(:post, /.*cancel\/cancel.cfm/).to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "cancel_order_ok.xml"))
        )
      end

      subject { Assist.cancel_order("1234567890") }

      it "shoud return CancelOrder instance" do
        expect(subject).to be_a Assist::WebServices::CancelOrder
      end

      it "shoud contain passed parameter" do
        expect(subject.request_params[:billnumber].to_s).to eq "1234567890"
      end

      it "should have been performed" do
        expect(subject.instance_variable_get("@response")).to be
      end
    end

    describe ".confirm_order" do
      before do
        stub_request(:post, /.*charge\/charge.cfm/).to_return(
          status: 200,
          body: File.read(File.join("spec", "fixtures", "confirm_order_ok.xml"))
        )
      end

      subject { Assist.confirm_order("1234567890") }

      it "shoud return CancelOrder instance" do
        expect(subject).to be_a Assist::WebServices::ConfirmOrder
      end

      it "shoud contain passed parameter" do
        expect(subject.request_params[:billnumber].to_s).to eq "1234567890"
      end

      it "should have been performed" do
        expect(subject.instance_variable_get("@response")).to be
      end
    end
  end

  describe ".setup" do
    after(:each) { clear_config }

    it "should set configuration" do
      Assist.setup { |config| assign_config_options(config) }

      required_config_options.each do |key, value|
        expect(Assist.config[key]).to eq value
      end
    end

    it "should clear previously set configuration" do
      Assist.setup do |config|
        assign_config_options(config)
        config.secret_word = 'secret'
      end
      expect(Assist.config.secret_word).to be

      Assist.setup { |config| assign_config_options(config) }
      expect(Assist.config.secret_word).to_not be
    end

    context "when configuration is not valid" do
      it "should raise an error" do
        expect{ Assist.setup {} }.to raise_error Assist::Exception::ConfigurationError
      end
    end
  end

  describe ".config" do
    context "when configuration is set" do
      before(:each) { set_config }
      after(:each) { clear_config }

      it "should return configuration" do
        expect(Assist.config).to be_a Assist::Configuration
      end
    end

    context "when configuration is not set" do
      it "should raise an error" do
        expect{ Assist.config }.to raise_error(Assist::Exception::ConfigurationError,
                                               "Configuration is not set")
      end
    end
  end
end
