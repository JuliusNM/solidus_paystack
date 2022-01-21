# frozen_string_literal: true

FactoryBot.define do
  factory :paystack_payment_method, class: SolidusPaystack::PaymentMethod do
    name { "Paystack" }
    preferred_public_api_key { "public000" }
    preferred_private_api_key { "private999" }
    preferred_currency { "" }
  end
end
