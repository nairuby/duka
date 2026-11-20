# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartItem, type: :model do
  let(:product) { Product.create!(name: "Ruby Mug", price: 1500.0, currency: "KES", category: "Mugs") }
  let(:variant) { Variant.create!(product: product, size: "Standard", color: "Red", stock_quantity: 15, sku: "MUG-RED-01") }
  let(:session_id) { SecureRandom.uuid }

  describe "validations" do
    it "is valid with a product, session_id, and positive quantity" do
      item = CartItem.new(product: product, session_id: session_id, quantity: 2)
      expect(item).to be_valid
    end

    it "is invalid without a session_id" do
      item = CartItem.new(product: product, quantity: 1)
      expect(item).not_to be_valid
      expect(item.errors[:session_id]).to be_present
    end

    it "is invalid with zero or negative quantity" do
      expect(CartItem.new(product: product, session_id: session_id, quantity: 0)).not_to be_valid
      expect(CartItem.new(product: product, session_id: session_id, quantity: -1)).not_to be_valid
    end

    it "enforces unique product and variant per session" do
      CartItem.create!(product: product, variant: variant, session_id: session_id, quantity: 1)
      duplicate = CartItem.new(product: product, variant: variant, session_id: session_id, quantity: 2)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:product_id]).to be_present
    end
  end

  describe "associations" do
    it "belongs to product" do
      assoc = described_class.reflect_on_association(:product)
      expect(assoc.macro).to eq(:belongs_to)
    end

    it "optionally belongs to variant" do
      assoc = described_class.reflect_on_association(:variant)
      expect(assoc.macro).to eq(:belongs_to)
      expect(assoc.options[:optional]).to be(true)
    end
  end

  describe "#subtotal" do
    it "calculates product price multiplied by quantity" do
      item = CartItem.new(product: product, quantity: 3)
      expect(item.subtotal).to eq(4500.0)
    end
  end

  describe "#display_name" do
    it "returns the product name when no variant is assigned" do
      item = CartItem.new(product: product)
      expect(item.display_name).to eq("Ruby Mug")
    end

    it "includes variant attributes when a variant is assigned" do
      item = CartItem.new(product: product, variant: variant)
      expect(item.display_name).to eq("Ruby Mug (Red, Standard)")
    end
  end
end
