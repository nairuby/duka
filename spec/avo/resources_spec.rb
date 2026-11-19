# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Avo Resources", type: :model do
  let(:user) { User.new(email: "a@b.com", admin: true) }
  let(:product) { Product.new(name: "Tee", price: 100, currency: "KES", category: "Shirts") }
  let(:variant) { Variant.new(product: product, size: "M", color: "Red", stock_quantity: 5, sku: "SKU1") }
  let(:order) { Order.new(order_number: "ORD-1", email: "a@b.com", total: 100, currency: "KES", status: "pending", payment_status: "pending") }
  let(:order_item) { OrderItem.new(order: order, product: product, price: 100, subtotal: 100, quantity: 1) }
  let(:payment_tx) { PaymentTransaction.new(order: order, transaction_type: "stk_push", status: "initiated", amount: 100, phone_number: "+254712345678") }
  let(:contact_msg) { ContactMessage.new(name: "Test", email: "a@b.com", subject: "Help", message: "Hello") }

  it "defines Product resource fields" do
    res = Avo::Resources::Product.new(record: product)
    expect { res.fields }.not_to raise_error
  end

  it "defines Order resource fields" do
    res = Avo::Resources::Order.new(record: order)
    expect { res.fields }.not_to raise_error
  end

  it "defines User resource fields" do
    res = Avo::Resources::User.new(record: user)
    expect { res.fields }.not_to raise_error
  end

  it "defines Variant resource fields" do
    res = Avo::Resources::Variant.new(record: variant)
    expect { res.fields }.not_to raise_error
  end

  it "defines OrderItem resource fields" do
    res = Avo::Resources::OrderItem.new(record: order_item)
    expect { res.fields }.not_to raise_error
  end

  it "defines PaymentTransaction resource fields" do
    res = Avo::Resources::PaymentTransaction.new(record: payment_tx)
    expect { res.fields }.not_to raise_error
  end

  it "defines ContactMessage resource fields" do
    res = Avo::Resources::ContactMessage.new(record: contact_msg)
    expect { res.fields }.not_to raise_error
  end
end
