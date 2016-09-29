require 'spec_helper'

describe Assist::Configuration do
  let(:config) { Assist::Configuration.new }

  describe "#validate!" do
    context "when all required options are provided" do
      it "should return nothing" do
        required_config_options.each do |key, value|
          config.public_send("#{key}=", value)
        end

        expect(config.validate!).to be_nil
      end
    end

    context "when there are missing required options" do
      it "should raise an error" do
        Assist::Configuration::REQUIRED_OPTIONS.each do |option|
          config.public_send("#{option}=", nil)

          required_config_options.delete_if { |k, v| k == option }.each do |key, value|
            config.public_send("#{key}=", value)
          end

          expect{ config.validate! }.to raise_error do |error|
            expect(error).to be_a Assist::Exception::ConfigurationError
            expect(error.message).to include("Missing configuration options")
            expect(error.message).to include(option.to_s)
          end
        end
      end
    end
  end

  describe "#endpoint" do
    context "when mode is production" do
      it "should return production endpoint" do
        config.mode = :production
        expect(config.endpoint).to eq Assist::Configuration::ENDPOINTS[:production]
      end
    end

    context "when mode is test" do
      it "should return test endpoint" do
        config.mode = :test
        expect(config.endpoint).to eq Assist::Configuration::ENDPOINTS[:test]
      end
    end

    context "when mode is somethihg else" do
      it "should return test endpoint" do
        config.mode = 'something'
        expect(config.endpoint).to eq Assist::Configuration::ENDPOINTS[:test]
      end
    end
  end

  describe "#checkvalue?" do
    context "when secret word is provided" do
      it "should return true" do
        config.secret_word = 'secret'
        expect(config.checkvalue?).to be_truthy
      end
    end

    context "when secret word is not provided" do
      it "should return false" do
        config.secret_word = nil
        expect(config.checkvalue?).to be_falsy
      end
    end

    context "when secret word is empty" do
      it "should return false" do
        config.secret_word = "  "
        expect(config.checkvalue?).to be_falsy
      end
    end
  end

  describe "#test_mode?" do
    context "when mode is production" do
      it "should return false" do
        config.mode = :production
        expect(config.send :test_mode?).to be_falsy
      end
    end

    context "when mode is test" do
      it "should return true" do
        config.mode = :test
        expect(config.send :test_mode?).to be_truthy
      end
    end

    context "when mode is somethihg else" do
      it "should return true" do
        config.mode = 'something'
        expect(config.send :test_mode?).to be_truthy
      end
    end
  end
end