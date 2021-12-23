# frozen_string_literal: true

FactoryBot.define do
  factory :paystack_payment, class: Spree::Payment do
    source_type { 'SolidusPaystack::Transaction' }
    state { 'checkout' }
  end

  factory :captured_paystack_payment, class: Spree::Payment do
    payment_method { create(:paystack_payment_method) }
    source { create(:paystack_transaction) }
  end
end
