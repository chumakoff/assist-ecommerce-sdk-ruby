$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'assist'
require 'webmock/rspec'

def required_config_options
  {login: "login", password: "password", merchant_id: "111111", mode: :test}
end

def assign_config_options(config)
  config.login = required_config_options[:login]
  config.password = required_config_options[:password]
  config.merchant_id = required_config_options[:merchant_id]
  config.mode = required_config_options[:mode]
end

def set_config
  Assist.setup do |config|
    assign_config_options(config)
    yield(config) if block_given?
  end
end

def clear_config
  Assist.instance_variable_set("@config", nil)
end
