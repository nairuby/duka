# == Schema Information
#
# Table name: variants
#
#  id             :uuid             not null, primary key
#  color          :string
#  size           :string
#  sku            :string
#  stock_quantity :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  product_id     :uuid             not null
#
# Indexes
#
#  index_variants_on_product_id  (product_id)
#  index_variants_on_sku         (sku) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class Variant < ApplicationRecord
  belongs_to :product
  
  validates :size, presence: true
  validates :color, presence: true
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true
end
