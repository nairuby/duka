class ChangePayloadsToBinaryInPaymentTransactions < ActiveRecord::Migration[8.1]
  def change
    remove_column :payment_transactions, :request_payload, :text
    remove_column :payment_transactions, :response_payload, :text
    add_column :payment_transactions, :raw_response, :jsonb
  end
end
