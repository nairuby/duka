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
require 'rails_helper'

RSpec.describe Product, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      product = Product.new(
        name: "Test Product",
        description: "Test description",
        price: 29.99,
        currency: "USD"
      )
      expect(product).to be_valid
    end

    it "is not valid without a name" do
      product = Product.new(price: 29.99, currency: "USD")
      expect(product).not_to be_valid
    end

    it "is not valid without a price" do
      product = Product.new(name: "Test Product", currency: "USD")
      expect(product).not_to be_valid
    end

    it "is not valid without a currency" do
      product = Product.new(name: "Test Product", price: 29.99)
      expect(product).not_to be_valid
    end

    it "is not valid with a negative price" do
      product = Product.new(name: "Test Product", price: -10, currency: "USD")
      expect(product).not_to be_valid
    end
  end

  describe "associations" do
    it "has many variants" do
      association = described_class.reflect_on_association(:variants)
      expect(association.macro).to eq :has_many
    end
  end
end
