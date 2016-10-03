require 'uri'
require 'net/http'
require 'rexml/document'
require 'assist/exception/api_error'
require 'assist/params_helper'

module Assist
  module WebServices
    class Base
      include ParamsHelper

      def initialize(extra_params)
        extra_params =
          normalize_keys(extra_params)
            .keep_if { |k| self.class::PERMITTED_EXTRA_PARAMS.include?(k) }
        @params = default_params.merge(extra_params)
      end

      def result
        @result ||= parse_result
      end

      def request_params
        params
      end

      def original_response
        response
      end

      private

      attr_reader :params

      def default_params
        {
          merchant_id: Assist.config.merchant_id,
          login: Assist.config.login,
          password: Assist.config.password,
          format: 3
        }
      end

      def response
        return @response if @response

        uri = URI(Assist.config.endpoint + self.class::SERVICE_PATH)
        @response = Net::HTTP.post_form(uri, params)
      end

      def response_xml
        return @response_xml if @response_xml

        if response.code != '200'
          raise Exception::APIError,
                "Invalid response: code=#{response.code}"
        end

        xml = REXML::Document.new(response.body)
        check_response!(xml)
        @response_xml = xml
      end

      def check_response!(xml)
        attrs = xml.elements["result"].attributes
        return if attrs["firstcode"].to_s == '0'

        raise Exception::APIError,
              "Assist API error: firstcode=#{attrs['firstcode']}, \
                secondcode=#{attrs['secondcode']}"
      end

      def parse_result
        raise NotImplementedError, "Must be implemented by subtypes"
      end
    end
  end
end
