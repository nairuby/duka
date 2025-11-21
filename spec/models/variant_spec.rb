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
require 'rails_helper'

RSpec.describe Variant, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
