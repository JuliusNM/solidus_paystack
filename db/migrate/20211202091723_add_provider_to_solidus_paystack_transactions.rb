class AddProviderToSolidusPaystackTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_paystack_transactions, :provider, :string, default: :paystack
  end
end
