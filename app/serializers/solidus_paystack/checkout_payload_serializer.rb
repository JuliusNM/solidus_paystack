# frozen_string_literal: true

require 'active_model_serializers'

module SolidusPaystack
  class CheckoutPayloadSerializer < ActiveModel::Serializer
    # rubocop:disable Layout/ArgumentAlignment
    attributes  :merchant, :shipping, :billing, :items, :discounts, :metadata,
                :order_id, :shipping_amount, :tax_amount, :total
    # rubocop:enable Layout/ArgumentAlignment

    def merchant
      hsh = {
        user_confirmation_url: object.config[:confirmation_url],
        user_cancel_url: object.config[:cancel_url]
      }
      hsh[:name] = object.config[:name] if object.config[:name].present?
      hsh
    end

    def shipping
      AddressSerializer.new(object.ship_address)
    end

    def billing
      AddressSerializer.new(object.bill_address)
    end

    def items
      ActiveModel::Serializer::CollectionSerializer.new(
        object.items,
        serializer: LineItemSerializer,
        root: false
      )
    end

    def discounts
      promo_total = object.order.promo_total
      return unless promo_total > 0

      {
        promotion_total: {
          discount_amount: promo_total.to_money.cents,
          discount_display_name: "Total promotion discount"
        }
      }
    end

    def order_id
      object.order.number
    end

    def shipping_amount
      object.order.shipment_total.to_money.cents
    end

    def tax_amount
      object.order.tax_total.to_money.cents
    end

    def total
      object.order.order_total_after_store_credit.to_money.cents
    end

    def metadata
      {
        platform_type: "Solidus",
        platform_version: Spree.solidus_version,
        platform_paystack: "Solidus::Paystack #{SolidusPaystack::VERSION}"
      }.merge(object.metadata)
    end
  end
end
