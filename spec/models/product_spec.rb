# == Schema Information
#
# Table name: products
#
#  id          :uuid             not null, primary key
#  currency    :string
#  description :text
#  image_url   :string
#  name        :string
#  price       :decimal(10, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Product, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
