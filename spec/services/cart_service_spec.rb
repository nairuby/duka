# frozen_string_literal: true

require "rails_helper"

RSpec.describe CartService do
  let(:session_id) { SecureRandom.uuid }
  let(:cart) { CartService.new(session_id) }
  let(:product) { Product.create!(name: "Ruby Cap", price: 1200.0, currency: "KES", category: "Hats") }
  let(:variant) { Variant.create!(product: product, size: "Adjustable", color: "Red", stock_quantity: 5, sku: "CAP-RED-ADJ") }

  describe "#add_item" do
    it "adds a new product to the cart" do
      expect {
        cart.add_item(product.id, quantity: 2)
      }.to change { cart.total_items }.from(0).to(2)

      item = cart.items.first
      expect(item.product).to eq(product)
      expect(item.quantity).to eq(2)
      expect(item.variant).to be_nil
    end

    it "adds a product with a variant" do
      cart.add_item(product.id, variant_id: variant.id, quantity: 3)
      item = cart.items.first
      expect(item.variant).to eq(variant)
      expect(item.quantity).to eq(3)
    end

    it "increments quantity when the same item is added again" do
      cart.add_item(product.id, variant_id: variant.id, quantity: 2)
      cart.add_item(product.id, variant_id: variant.id, quantity: 2)

      expect(cart.items.count).to eq(1)
      expect(cart.items.first.quantity).to eq(4)
    end

    it "raises an error if added quantity exceeds variant stock" do
      expect {
        cart.add_item(product.id, variant_id: variant.id, quantity: 6)
      }.to raise_error(/available in stock/)
    end
  end

  describe "#update_quantity" do
    let!(:item) { cart.add_item(product.id, variant_id: variant.id, quantity: 2) }

    it "updates the quantity of an existing item" do
      cart.update_quantity(item.id, 4)
      expect(item.reload.quantity).to eq(4)
    end

    it "raises an error if updated quantity exceeds stock" do
      expect {
        cart.update_quantity(item.id, 10)
      }.to raise_error(/available in stock/)
    end

    it "destroys the item if quantity is set to 0 or less" do
      expect {
        cart.update_quantity(item.id, 0)
      }.to change { cart.items.count }.from(1).to(0)
    end
  end

  describe "#remove_item and #clear" do
    let!(:item) { cart.add_item(product.id, quantity: 2) }

    it "removes a single item" do
      expect {
        cart.remove_item(item.id)
      }.to change { cart.items.count }.from(1).to(0)
    end

    it "clears all items in the cart" do
      another_product = Product.create!(name: "Sticker", price: 200.0, currency: "KES", category: "Stickers")
      cart.add_item(another_product.id, quantity: 3)

      expect(cart.items.count).to eq(2)
      cart.clear
      expect(cart.empty?).to be(true)
      expect(cart.total_items).to eq(0)
    end
  end

  describe "calculations" do
    let(:product2) { Product.create!(name: "Sticker", price: 300.0, currency: "KES", category: "Stickers") }

    before do
      cart.add_item(product.id, quantity: 2) # 2 * 1200 = 2400
      cart.add_item(product2.id, quantity: 3) # 3 * 300 = 900
    end

    it "calculates total items" do
      expect(cart.total_items).to eq(5)
    end

    it "calculates subtotal and total" do
      expect(cart.subtotal).to eq(3300.0)
      expect(cart.total).to eq(3300.0)
    end
  end

  describe "#suggested_products" do
    it "returns products when cart is empty" do
      empty_cart = CartService.new(SecureRandom.uuid)
      expect(empty_cart.suggested_products).to be_an(ActiveRecord::Relation)
    end

    it "excludes items already present in the cart" do
      cart.add_item(product.id, quantity: 1)
      suggested = cart.suggested_products
      expect(suggested.pluck(:id)).not_to include(product.id)
    end
  end
end
