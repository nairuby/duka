class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.string :status, null: false, default: 'cart'
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.string :session_token
      t.string :user_email
      t.jsonb :shipping_address
      t.jsonb :billing_address

      t.timestamps
    end

    add_index :orders, :session_token
  end
end
