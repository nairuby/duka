# == Schema Information
#
# Table name: products
#
#  id          :uuid             not null, primary key
#  category    :string
#  currency    :string
#  description :text
#  image_url   :string
#  name        :string
#  price       :decimal(10, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_products_on_category  (category)
#
class Product < ApplicationRecord
  has_many :variants, dependent: :destroy

  CATEGORIES = %w[Shirts Hoodies Hats Bags Mugs Stickers Accessories].freeze

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  scope :by_category, ->(category) { where(category: category) }
end
