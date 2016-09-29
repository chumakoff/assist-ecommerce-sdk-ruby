require "assist/configuration"
require "assist/payment_interface"
require "assist/api_methods"
require 'assist/exception/configuration_error'

module Assist
  extend ApiMethods

  class << self
    def payment_url(*args)
      PaymentInterface.new(*args).url
    end

    def setup
      self.config = Configuration.new
      yield config
      config.validate!
    end

    def config
      return @config if @config

      raise Exception::ConfigurationError, "Configuration is not set"
    end

    private

    attr_writer :config
  end
end
