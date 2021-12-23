# frozen_string_literal: true

require 'active_model_serializers'

module SolidusPaystack
  # This class represents the json payload needed for the Paystack checkout.
  # It will escapsulate the +Spree::Order+ and the needed configuration and
  # meta data that will be serialized and send as JSON to Paystack.
  #
  # @!attribute [r] order
  #   [Spree::Order] The +Spree::Order+ instance that will be send to Paystack by
  #   serializing this Object.
  # @!attribute [r] config
  #   [Hash] The configuration for Paystack, this hash expects the following keys:
  #   +:user_confirmation_url+ and +:user_cancel_url+
  #   and if you specify the optional +:name+ configuration, that will also be used.
  # @!attribute [r] metadata
  #   [Hash] Paystack support arbitrary key:value metadata, we pass this hash
  #   directly to Paystack if it's present.
  # @see CheckoutPayloadSerializer
  class CheckoutPayload < ActiveModelSerializers::Model
    attr_reader :order, :config, :metadata

    delegate :ship_address, :bill_address, to: :order

    # @param order [Spree::Order]
    # @param config [Hash]
    # @option config [String] :user_confirmation_url The redirect url for successful Paystack checkout
    # @option config [String] :user_cancel_url The redirect url for a canceled Paystack checkout
    # @option config [String] :name The shop name to display in the Paystack checkout.
    # @param metadata [Hash]
    def initialize(order, config, metadata = {})
      @order = order
      @config = config
      @metadata = metadata
    end

    def items
      order.line_items
    end
  end
end
