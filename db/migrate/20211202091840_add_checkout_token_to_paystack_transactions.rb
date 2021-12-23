class AddCheckoutTokenToPaystackTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_paystack_transactions, :checkout_token, :string
  end
end
