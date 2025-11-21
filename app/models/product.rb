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
class Product < ApplicationRecord
  has_many :variants, dependent: :destroy
  
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
end
