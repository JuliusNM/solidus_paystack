# frozen_string_literal: true

module SolidusPaystack
  module Spree::OrderDecorator
    def self.prepended(base)
      base.remove_checkout_step :confirm
    end

    ::Spree::Order.prepend self
    end
end
