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

def stub_order_status_requests
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

def stub_cancel_order_requests
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
