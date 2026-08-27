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
  let(:product) { Product.create!(name: "Test Product", price: 29.99, currency: "USD") }

  describe "validations" do
    it "is valid with valid attributes" do
      variant = Variant.new(
        product: product,
        size: "M",
        color: "Red",
        stock_quantity: 10,
        sku: "TEST-M-RED-001"
      )
      expect(variant).to be_valid
    end

    it "is not valid without a size" do
      variant = Variant.new(product: product, color: "Red", stock_quantity: 10, sku: "TEST-001")
      expect(variant).not_to be_valid
    end

    it "is not valid without a color" do
      variant = Variant.new(product: product, size: "M", stock_quantity: 10, sku: "TEST-001")
      expect(variant).not_to be_valid
    end

    it "is not valid without a stock_quantity" do
      variant = Variant.new(product: product, size: "M", color: "Red", sku: "TEST-001")
      expect(variant).not_to be_valid
    end

    it "is not valid without a sku" do
      variant = Variant.new(product: product, size: "M", color: "Red", stock_quantity: 10)
      expect(variant).not_to be_valid
    end

    it "is not valid with a negative stock_quantity" do
      variant = Variant.new(product: product, size: "M", color: "Red", stock_quantity: -1, sku: "TEST-001")
      expect(variant).not_to be_valid
    end

    it "is not valid with a duplicate sku" do
      Variant.create!(product: product, size: "M", color: "Red", stock_quantity: 10, sku: "TEST-001")
      variant = Variant.new(product: product, size: "L", color: "Blue", stock_quantity: 5, sku: "TEST-001")
      expect(variant).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to product" do
      association = described_class.reflect_on_association(:product)
      expect(association.macro).to eq :belongs_to
    end
  end
end
