# frozen_string_literal: true

module Spree
  module Paystack
    class CallbackController < Spree::StoreController
      protect_from_forgery except: [:confirm]

      def confirm
        case paystack_params["event"]
        when "charge.success"
          # Await Solidus to complete transitioning order states
          sleep 1.5
          transaction_ref = paystack_params["data"]["reference"]
          if valid_transaction?(transaction_ref)
            checkout_token = paystack_params["data"]["authorization"]["authorization_code"]

            unless checkout_token
              return redirect_to checkout_state_path(order.state), notice: "Invalid order confirmation data passed in"
            end

            order = Spree::Order.find_by(number: transaction_ref)
            if order && order.payment_state == 'balance_due'
              payment_method = SolidusPaystack::PaymentMethod.first

              paystack_source_transaction = SolidusPaystack::Transaction.new(
                transaction_id: paystack_params["data"]["id"],
                checkout_token: checkout_token,
                provider: 'paystack'
              )

              paystack_source_transaction.transaction do
                if paystack_source_transaction.save!
                  paystack_payment = order.payments.where(payment_method_id: payment_method.id).first
                  paystack_payment&.update!(
                    payment_method_id: payment_method.id,
                    source: paystack_source_transaction,
                    amount: order.total,
                    state: 'completed'
                  )
                  order.payment_total = order.total
                  order.save!
                  head :ok
                end
              end
            end
          else
            head :unauthorized
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
