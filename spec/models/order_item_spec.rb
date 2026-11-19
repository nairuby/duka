# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderItem, type: :model do
  let(:product) { Product.create!(name: "Ruby Hoodie", price: 4500.0, currency: "KES", category: "Hoodies") }
  let(:variant) { Variant.create!(product: product, size: "L", color: "Black", stock_quantity: 10, sku: "HOODIE-L-BLK") }
  let(:order) do
    Order.create!(
      email: "order@example.com",
      phone: "0712345678",
      shipping_name: "Buyer",
      shipping_address: "123 Way",
      shipping_city: "Nairobi",
      shipping_postal_code: "00100",
      shipping_country: "Kenya",
      subtotal: 4500.0,
      total: 4500.0,
      status: "pending",
      payment_status: "pending"
    )
  end

  describe "validations and creation callbacks" do
    it "sets price and calculates subtotal automatically from product" do
      order_item = OrderItem.create!(
        order: order,
        product: product,
        quantity: 2
      )

      expect(order_item.price).to eq(4500.0)
      expect(order_item.subtotal).to eq(9000.0)
      expect(order_item.product_name).to eq("Ruby Hoodie")
      expect(order_item.variant_details).to be_nil
    end

    it "snapshots variant details when variant is attached" do
      order_item = OrderItem.create!(
        order: order,
        product: product,
        variant: variant,
        quantity: 1
      )

      expect(order_item.variant_details).to eq("L / Black")
    end

    it "is invalid with zero or negative quantity" do
      item = OrderItem.new(order: order, product: product, quantity: 0)
      expect(item).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to order" do
      expect(described_class.reflect_on_association(:order).macro).to eq(:belongs_to)
    end

    it "belongs to product" do
      expect(described_class.reflect_on_association(:product).macro).to eq(:belongs_to)
    end

    it "optionally belongs to variant" do
      assoc = described_class.reflect_on_association(:variant)
      expect(assoc.macro).to eq(:belongs_to)
      expect(assoc.options[:optional]).to be(true)
    end
  end
end
