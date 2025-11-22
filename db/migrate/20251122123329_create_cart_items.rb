class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items, id: :uuid do |t|
      t.string :session_id, null: false
      t.uuid :product_id, null: false
      t.uuid :variant_id
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end

    add_index :cart_items, :session_id
    add_index :cart_items, :product_id
    add_index :cart_items, [ :session_id, :product_id, :variant_id ], unique: true, name: 'index_cart_items_unique'
    add_foreign_key :cart_items, :products
  end
end
