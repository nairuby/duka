# == Schema Information
#
# Table name: order_items
#
#  id              :uuid             not null, primary key
#  price           :decimal(10, 2)   not null
#  product_name    :string
#  quantity        :integer          default(1), not null
#  subtotal        :decimal(10, 2)   not null
#  variant_details :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  order_id        :uuid             not null
#  product_id      :uuid             not null
#  variant_id      :uuid
#
# Indexes
#
#  index_order_items_on_order_id    (order_id)
#  index_order_items_on_product_id  (product_id)
#  index_order_items_on_variant_id  (variant_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (variant_id => variants.id)
#
require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
