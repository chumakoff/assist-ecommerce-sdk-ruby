require 'spec_helper'

describe Assist do
  it "has a version number" do
    expect(Assist::VERSION).not_to be nil
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
