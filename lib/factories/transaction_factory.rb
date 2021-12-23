# frozen_string_literal: true

FactoryBot.define do
  factory :paystack_transaction, class: SolidusPaystack::Transaction do
    checkout_token { "TKLKJ71GOP9YSASU" }
    transaction_id { 'LS-1HQX-UA1Y' }
    provider { "paystack" }
  end
end
