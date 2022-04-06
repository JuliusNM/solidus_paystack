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
            transaction_ref = transaction_ref.partition('_').first
            checkout_token = paystack_params["data"]["authorization"]["authorization_code"]

            unless checkout_token
              return redirect_to checkout_state_path(order.state), notice: "Invalid order confirmation data passed in"
            end

            order = Spree::Order.find_by(number: transaction_ref)
            if order
              order.reload
              complete_order(order) unless order.complete?
              process_order(order, checkout_token, paystack_params["data"]["id"])
            else
              head :not_found
            end
          else
            head :unauthorized
          end
        end
      end

      def sanity_check(order)
        order.can_complete? && order.payment_state.nil?
      end

      def cancel
        order = Spree::Order.find(paystack_params[:order_id])
        hook = SolidusPaystack::Config.callback_hook.new
        redirect_to hook.after_cancel_url(order)
      end

      private

      def valid_transaction?(ref)
        paystack = paystack_payment_method
        SolidusPaystack::Gateway.new({ private_api_key: paystack.preferred_private_api_key}).verify_transaction(ref)
      end

      def complete_order(order)
        if sanity_check(order)
          create_order_payment(order)
          order.complete!
        end
      end

      def process_order(order, checkout_token, transaction_id)
        if order.payment_state == 'balance_due'
          payment_method = paystack_payment_method
          paystack_source_transaction = create_paystack_transaction(checkout_token, transaction_id)

          paystack_source_transaction.transaction do
            if paystack_source_transaction.save!
              paystack_payment = order.payments.where(payment_method_id: payment_method.id).first
              update_order_payment(paystack_payment, payment_method.id, paystack_source_transaction, order)
              order.payment_total = order.total
              order.save!
              head :ok
            end
          end
        end
      end

      def create_paystack_transaction(checkout_token, transaction_id)
          SolidusPaystack::Transaction.new(
            transaction_id: transaction_id,
            checkout_token: checkout_token,
            provider: 'paystack'
          )
      end

      def create_order_payment(order)
        payment_method = paystack_payment_method
        order.payments.create(payment_method_id: payment_method.id)
      end

      def paystack_payment_method
        SolidusPaystack::PaymentMethod.first
      end

      def update_order_payment(paystack_payment, payment_method_id, source_transaction, order)
        paystack_payment&.update!(
          payment_method_id: payment_method_id,
          source: source_transaction,
          amount: order.total,
          state: 'completed'
        )
      end

      def paystack_params
        # TODO::Strict Params
        params.permit!
      end
    end
  end
end
