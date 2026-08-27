class CreateLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :line_items, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :variant, null: true, foreign_key: true, type: :uuid
      t.integer :quantity, null: false, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :line_items, [ :order_id, :product_id ]
  end
end
