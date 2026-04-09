class RemoveMpesaFieldsFromOrders < ActiveRecord::Migration[8.1]
  def change
    remove_column :orders, :mpesa_checkout_request_id, :string
    remove_column :orders, :mpesa_transaction_id, :string
    remove_column :orders, :mpesa_receipt_number, :string
  end
end
