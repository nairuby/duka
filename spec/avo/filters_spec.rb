# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Avo Filters", type: :model do
  describe Avo::Filters::CategoryFilter do
    let(:filter) { described_class.new }

    it "has valid category options" do
      expect(filter.options.keys).to include("Shirts", "Hoodies")
    end

    it "applies category condition to query" do
      product1 = Product.create!(name: "Ruby Shirt", price: 1000, currency: "KES", category: "Shirts")
      product2 = Product.create!(name: "Ruby Mug", price: 1000, currency: "KES", category: "Mugs")

      filtered = filter.apply(nil, Product.all, "Shirts")
      expect(filtered).to include(product1)
      expect(filtered).not_to include(product2)
    end
  end

  describe Avo::Filters::LowStockFilter do
    let(:filter) { described_class.new }
    let(:product) { Product.create!(name: "Test P", price: 1000, currency: "KES", category: "Shirts") }

    it "has stock options" do
      expect(filter.options).to have_key(:low_stock)
      expect(filter.options).to have_key(:out_of_stock)
      expect(filter.options).to have_key(:in_stock)
    end

    it "filters variants by low stock, out of stock, and in stock" do
      out_of_stock = Variant.create!(product: product, size: "S", color: "Red", stock_quantity: 0, sku: "V-0")
      low_stock = Variant.create!(product: product, size: "M", color: "Red", stock_quantity: 4, sku: "V-4")
      in_stock = Variant.create!(product: product, size: "L", color: "Red", stock_quantity: 20, sku: "V-20")

      res_low = filter.apply(nil, Variant.all, { "low_stock" => true })
      expect(res_low).to include(out_of_stock, low_stock)
      expect(res_low).not_to include(in_stock)

      res_out = filter.apply(nil, Variant.all, { "out_of_stock" => true })
      expect(res_out).to include(out_of_stock)
      expect(res_out).not_to include(in_stock)

      res_in = filter.apply(nil, Variant.all, { "in_stock" => true })
      expect(res_in).to include(low_stock, in_stock)
      expect(res_in).not_to include(out_of_stock)
    end
  end

  describe Avo::Filters::OrderStatusFilter do
    let(:filter) { described_class.new }

    it "has order status options" do
      expect(filter.options.values).to include("pending", "confirmed")
    end

    it "applies status filter to query" do
      order1 = Order.create!(email: "a@b.com", phone: "071", shipping_name: "A", shipping_address: "A", shipping_city: "A", shipping_postal_code: "1", shipping_country: "KE", subtotal: 10, total: 10, status: "pending", payment_status: "pending")
      order2 = Order.create!(email: "c@d.com", phone: "072", shipping_name: "B", shipping_address: "B", shipping_city: "B", shipping_postal_code: "2", shipping_country: "KE", subtotal: 10, total: 10, status: "confirmed", payment_status: "pending")

      res = filter.apply(nil, Order.all, "confirmed")
      expect(res).to include(order2)
      expect(res).not_to include(order1)
    end
  end

  describe Avo::Filters::PaymentStatusFilter do
    let(:filter) { described_class.new }

    it "has payment status options" do
      expect(filter.options.values).to include("pending", "paid")
    end

    it "applies payment_status filter to query" do
      order1 = Order.create!(email: "a@b.com", phone: "071", shipping_name: "A", shipping_address: "A", shipping_city: "A", shipping_postal_code: "1", shipping_country: "KE", subtotal: 10, total: 10, status: "pending", payment_status: "pending")
      order2 = Order.create!(email: "c@d.com", phone: "072", shipping_name: "B", shipping_address: "B", shipping_city: "B", shipping_postal_code: "2", shipping_country: "KE", subtotal: 10, total: 10, status: "confirmed", payment_status: "paid")

      res = filter.apply(nil, Order.all, "paid")
      expect(res).to include(order2)
      expect(res).not_to include(order1)
    end
  end
end
