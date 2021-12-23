class AddSolidusPaystackTransaction < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_paystack_transactions do |t|
      t.string :transaction_id
      t.timestamps
    end
  end
end
