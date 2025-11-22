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
require 'rails_helper'

RSpec.describe CartItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
