# frozen_string_literal: true

module SolidusPaystack
  class Gateway
    API_URL = 'https://api.paystack.co'

    attr_reader :api_key

    def initialize(options)
      @api_key = options.fetch(:private_api_key)
    end

    def credit(money, transaction_id, _options = {})
      response = request(
        :post,
        "/refund",
        payload_for_refund(money, _options),
      )

      if response.success?
        ActiveMerchant::Billing::Response.new(true, "Transaction Credited with #{money}")
      else
        ActiveMerchant::Billing::Response.new(false, "Credit Failed: #{response}")
      end

    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message)
    end

    def void(transaction_id, _money, _options = {})
      ActiveMerchant::Billing::Response.new(false, "Not Applicable")
    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message)
    end

    def verify_transaction(ref)
      response = request(
        :get,
        "/transaction/verify/#{ref}"
      )
      response.success?
    end

    private

    def request(method, uri, body = {})
      HTTParty.send(
        method,
        "#{API_URL}#{uri}",
        headers: {
          "Authorization" => "Bearer #{api_key}",
          "Content-Type" => "application/json",
          "Accept" => "application/json",
        },
        body: body.to_json,
      )
    end

    def payload_for_refund(money, options = {})
      paystack_transaction = get_transaction(options[:originator].payment_id)
      transaction_amount = options[:originator].amount * 100
      {
        transaction: paystack_transaction,
        amount: transaction_amount,
        currency: options[:currency],
        merchant_note: "Payment #{options[:order_id]}",
        customer_note: options[:billing_address],
      }

    end

    def get_transaction(payment_id)
      payment = Spree::Payment.find payment_id
      payment&.source&.transaction_id
    end
  end
end
