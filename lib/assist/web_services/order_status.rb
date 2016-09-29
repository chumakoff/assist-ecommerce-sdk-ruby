require 'assist/web_services/base'
require 'assist/checkvalue_generator'

module Assist
  module WebServices
    class OrderStatus < Base
      include CheckvalueGenerator

      SERVICE_PATH = "/orderstate/orderstate.cfm".freeze

      PERMITTED_EXTRA_PARAMS = %w(
        StartYear StartMonth StartDay StartHour StartMin
        EndYear EndMonth EndDay EndHour EndMin
      ).map(&normalize_block).freeze

      def initialize(order_number, extra_params = {})
        super(extra_params)
        @params[:ordernumber] = order_number
      end

      def status
        result.last.fetch(:orderstate)
      end

      def billnumber
        result.last.fetch(:billnumber)
      end

      private

      def parse_result
        result =
          response_xml.elements.each("result/order") {}.map do |el|
            Hash[el.elements.map { |e| [normalize(e.name), e.text] }]
          end
        verify_checkvalue!(result.last) if Assist.config.checkvalue?
        result
      end

      def verify_checkvalue!(attrs)
        checkvalue = attrs.delete(:checkvalue)
        hash = {}

        [:orderamount, :ordercurrency, :orderstate].each do |attr_name|
          hash[attr_name] = attrs[attr_name]
        end

        [:merchant_id, :ordernumber].each do |attr_name|
          hash[attr_name] = params[attr_name]
        end

        return if checkvalue == generate_checkvalue(hash, '')
        raise Exception::APIError, "Wrong checkvalue"
      end
    end
  end
end
