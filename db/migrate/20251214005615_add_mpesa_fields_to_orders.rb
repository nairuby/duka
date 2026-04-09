class AddMpesaFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :mpesa_checkout_request_id, :string
    add_column :orders, :mpesa_transaction_id, :string
    add_column :orders, :mpesa_receipt_number, :string
    add_column :orders, :payment_initiated_at, :datetime
    add_column :orders, :payment_completed_at, :datetime
    add_column :orders, :payment_timeout_at, :datetime

    # Add indexes for M-Pesa fields for efficient lookups
    add_index :orders, :mpesa_checkout_request_id
    add_index :orders, :mpesa_transaction_id
    add_index :orders, :mpesa_receipt_number
  end
end
