require 'uri'
require 'assist/checkvalue_generator'
require 'assist/params_helper'

module Assist
  class PaymentInterface
    include CheckvalueGenerator
    include ParamsHelper

    SERVICE_PATH = "/pay/order.cfm".freeze

    PERMITTED_EXTRA_PARAMS = %w(
      OrderCurrency Language OrderComment Lastname Firstname Middlename
      Email Address HomePhone WorkPhone MobilePhone Fax Country State City
      Zip MobileDevice Delay URL_RETURN URL_RETURN_OK URL_RETURN_NO
      CardPayment YMPayment WMPayment QIWIPayment
      QIWIMtsPayment QIWIMegafonPayment QIWIBeelinePayment QIWITele2Payment
    ).map(&normalize_block).freeze

    PAYMENT_METHODS_MAPPING = {card: :cardpayment, ym: :ympayment,
                               wm: :wmpayment, qiwi: :qiwipayment}.freeze
    QIWI_METHODS_MAPPING =
      {
        mts: :qiwimtspayment, megafon: :qiwimegafonpayment,
        beeline: :qiwibeelinepayment, tele2: :qiwitele2payment
      }.freeze

    def initialize(order_number, order_amount, extra_params = {})
      extra_params = normalize_keys(extra_params)
      extra_params.keep_if { |key| PERMITTED_EXTRA_PARAMS.include?(key) }

      params.merge!(extra_params)
      params.merge!(ordernumber: order_number, orderamount: order_amount)

      return unless Assist.config.checkvalue?
      params[:checkvalue] = generate_checkvalue(params)
    end

    def url
      uri = URI(Assist.config.endpoint + SERVICE_PATH)
      uri.query = URI.encode_www_form(params)
      uri.to_s
    end

    private

    def params
      @params ||= default_params
    end

    def default_params
      attrs = {merchant_id: Assist.config.merchant_id}

      {
        return_url: :url_return,
        success_url: :url_return_ok,
        fail_url: :url_return_no
      }
      .each do |key, value|
        attrs[value] = Assist.config[key] if Assist.config[key]
      end

      attrs.merge!(payment_methods_params) if Assist.config.payment_methods
      attrs
    end

    def payment_methods_params
      attrs = {}

      PAYMENT_METHODS_MAPPING.each do |key, value|
        attrs[value] = 0 unless Assist.config.payment_methods[key]
      end

      if Assist.config.payment_methods[:qiwi].is_a?(Hash)
        QIWI_METHODS_MAPPING.each do |key, value|
          attrs[value] = 0 unless Assist.config.payment_methods[:qiwi][key]
        end
      end

      attrs
    end
  end
end
