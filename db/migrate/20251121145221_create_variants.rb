class CreateVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :variants, id: :uuid do |t|
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.string :size
      t.string :color
      t.integer :stock_quantity
      t.string :sku

      t.timestamps
    end
    
    add_index :variants, :sku, unique: true
  end
end
