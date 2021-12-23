# frozen_string_literal: true

module SolidusPaystack
  class Transaction < Spree::PaymentSource
    self.table_name = "solidus_paystack_transactions"
  end
end
