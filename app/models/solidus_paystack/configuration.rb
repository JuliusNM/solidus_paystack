# frozen_string_literal: true

module SolidusPaystack
  class Configuration < Spree::Preferences::Configuration
    attr_writer :callback_controller_name, :callback_hook, :checkout_payload_serializer

    # Allows implementing custom controller for handling the confirming
    #  and canceling callbacks from Paystack.
    # @!attribute [rw] callback_controller_name
    # @see Spree::Paystack::CallbackController
    # @return [String] The controller name used in the routes file.
    #   The standard controller is the 'paystack' controller
    def callback_controller_name
      @callback_controller_name ||= "callback"
    end

    # Allows implementing custom callback hook for confirming and canceling
    #  callbacks from Paystack.
    # @!attribute [rw] callback_hook
    # @see SolidusPaystack::CallbackHook::Base
    # @return [Class] an object that conforms to the API of
    #   the standard callback hook class SolidusPaystack::CallbackHook::Base.
    def callback_hook
      @callback_hook ||= SolidusPaystack::CallbackHook::Base
    end

    # Allows overriding the main checkout payload serializer
    # @!attribute [rw] checkout_payload_serializer
    # @see SolidusPaystack::CheckoutPayloadSerializer
    # @return [Class] The serializer class that will be used for serializing
    #  the +SolidusPaystack::CheckoutPayload+ object.
    def checkout_payload_serializer
      @checkout_payload_serializer ||= SolidusPaystack::CheckoutPayloadSerializer
    end

  end
end
