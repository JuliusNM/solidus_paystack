# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusPaystack
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_paystack'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "register_solidus_paystack_payment_method", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << SolidusPaystack::PaymentMethod
    end

    initializer "register_solidus_paystack_configuration", before: :load_config_initializers do |_app|
      SolidusPaystack::Config = SolidusPaystack::Configuration.new
    end

  end
end
