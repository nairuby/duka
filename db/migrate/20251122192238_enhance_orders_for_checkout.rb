class EnhanceOrdersForCheckout < ActiveRecord::Migration[8.1]
  def change
    # Add new columns to orders table
    add_column :orders, :order_number, :string
    add_column :orders, :email, :string
    add_column :orders, :phone, :string
    add_column :orders, :payment_method, :string
    add_column :orders, :payment_status, :string, default: 'pending'
    add_column :orders, :payment_reference, :string
    add_column :orders, :subtotal, :decimal, precision: 10, scale: 2
    add_column :orders, :shipping_cost, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :currency, :string, default: 'KES'
    add_column :orders, :shipping_name, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :shipping_country, :string, default: 'Kenya'
    add_column :orders, :notes, :text

    # Add indexes (skip if already exists)
    add_index :orders, :order_number, unique: true unless index_exists?(:orders, :order_number)
    add_index :orders, :status unless index_exists?(:orders, :status)
    add_index :orders, :payment_status unless index_exists?(:orders, :payment_status)
    add_index :orders, :email unless index_exists?(:orders, :email)

    # Create order_items table
    create_table :order_items, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :variant, null: true, foreign_key: true, type: :uuid
      t.integer :quantity, null: false, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.string :product_name
      t.string :variant_details

      t.timestamps
    end

    add_index :order_items, :order_id unless index_exists?(:order_items, :order_id)
  end
end
