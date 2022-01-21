# frozen_string_literal: true

module SolidusPaystack
  class PaymentMethod < Spree::PaymentMethod
    preference :public_api_key, :string
    preference :private_api_key, :string
    preference :currency, :string

    delegate :try_void, to: :gateway

    def payment_source_class
      Transaction
    end

    def source_required?
      false
    end

    def partial_name
      'paystack'
    end

    def supports?(source)
      source.is_a? payment_source_class
    end

    def payment_profiles_supported?
      false
    end

    protected

    def gateway_class
      Gateway
    end
  end
end
