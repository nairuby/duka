class AddImageUrlToVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :variants, :image_url, :string
  end
end
