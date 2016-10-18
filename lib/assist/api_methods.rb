require 'assist/web_services/order_status'
require 'assist/web_services/cancel_order'
require 'assist/web_services/confirm_order'

module Assist
  module ApiMethods
    def order_status(*args)
      WebServices::OrderStatus.new(*args).perform
    end

    def cancel_order(*args)
      WebServices::CancelOrder.new(*args).perform
    end

    def confirm_order(*args)
      WebServices::ConfirmOrder.new(*args).perform
    end
  end
end
