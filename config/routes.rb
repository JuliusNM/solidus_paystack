# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  default_url_options host: "example.com"

  namespace :paystack do
    post 'confirm', controller: SolidusPaystack::Config.callback_controller_name
    get 'cancel', controller: SolidusPaystack::Config.callback_controller_name
  end
end
