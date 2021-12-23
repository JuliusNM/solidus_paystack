# frozen_string_literal: true

module Spree
  module Paystack
    class CallbackController < Spree::StoreController
      protect_from_forgery except: [:confirm]

      def confirm
        case paystack_params["event"]
        when "charge.success"

          transaction_ref = paystack_params["data"]["reference"]
          if valid_transaction?(transaction_ref)
            checkout_token = paystack_params["data"]["authorization"]["authorization_code"]

            unless checkout_token
              return redirect_to checkout_state_path(order.state), notice: "Invalid order confirmation data passed in"
            end

            order = Spree::Order.find(transaction_ref)
            payment_method = SolidusPaystack::PaymentMethod.first

            if order.complete?
              return redirect_to spree.order_path(order), notice: "Order is already in complete state"
            end

            paystack_source_transaction = SolidusPaystack::Transaction.new(
              transaction_id: paystack_params["data"]["id"],
              checkout_token: checkout_token,
              provider: 'paystack'
            )

            paystack_source_transaction.transaction do
              if paystack_source_transaction.save!
                order.payments.create!(
                  {
                    payment_method_id: payment_method.id,
                    source: paystack_source_transaction,
                    amount: order.total,
                    state: 'completed'
                  }
                )
                order.payment_total = order.total
                order.save!
                order.next!

                redirect_to checkout_state_path(order.state)
              end
            end
          end
        end
      end

      def cancel
        order = Spree::Order.find(paystack_params[:order_id])
        hook = SolidusPaystack::Config.callback_hook.new
        redirect_to hook.after_cancel_url(order)
      end

      private

      def valid_transaction?(ref)
        paystack = SolidusPaystack::PaymentMethod.first
        SolidusPaystack::Gateway.new({ private_api_key: paystack.preferred_private_api_key}).verify_transaction(ref)
      end

      def paystack_params
        # TODO::Strict Params
        params.permit!
      end
    end
  end
end
