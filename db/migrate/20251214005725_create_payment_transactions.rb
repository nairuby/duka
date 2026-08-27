class CreatePaymentTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_transactions, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.string :transaction_type, null: false
      t.string :status, null: false
      t.string :external_reference
      t.decimal :amount, precision: 10, scale: 2
      t.string :phone_number
      t.text :request_payload
      t.text :response_payload
      t.datetime :processed_at
      t.text :error_message

      t.timestamps
    end

    # Add indexes for efficient lookups
    add_index :payment_transactions, :transaction_type
    add_index :payment_transactions, :status
    add_index :payment_transactions, :external_reference
    add_index :payment_transactions, :phone_number
    add_index :payment_transactions, :processed_at
  end
end
