require 'assist/web_services/order_status'
require 'assist/web_services/cancel_order'

module Assist
  module ApiMethods
    def order_status(*args)
      WebServices::OrderStatus.new(*args)
    end

    def cancel_order(*args)
      WebServices::CancelOrder.new(*args)
    end
  end
end
