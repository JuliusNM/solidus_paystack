# frozen_string_literal: true

module SolidusPaystack
  module CallbackHook
    class Base
      def after_cancel_url(order)
        Spree::Core::Engine.routes.url_helpers.checkout_state_path(order.state)
      end
    end
  end
end
