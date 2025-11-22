# == Schema Information
#
# Table name: cart_items
#
#  id         :uuid             not null, primary key
#  quantity   :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :uuid             not null
#  session_id :string           not null
#  variant_id :uuid
#
# Indexes
#
#  index_cart_items_on_product_id  (product_id)
#  index_cart_items_on_session_id  (session_id)
#  index_cart_items_unique         (session_id,product_id,variant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class CartItem < ApplicationRecord
  belongs_to :product
  belongs_to :variant, optional: true

  validates :session_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: [ :session_id, :variant_id ] }

  def subtotal
    product.price * quantity
  end

  def display_name
    name = product.name
    name += " (#{variant.color}, #{variant.size})" if variant
    name
  end
end
