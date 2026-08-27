require "rails_helper"
include ActionView::Helpers::NumberHelper

RSpec.describe OrderMailer, type: :mailer do
  describe "confirmation" do
    let(:product) { Product.create!(name: "Test Product", price: 1000, currency: "KES") }
    let(:order) do
      Order.create!(
        email: "customer@example.com",
        phone: "0712345678",
        shipping_name: "Jane Doe",
        shipping_address: "123 Street",
        shipping_city: "Nairobi",
        shipping_postal_code: "00100",
        shipping_country: "Kenya",
        subtotal: 1000,
        total: 1000,
        status: "confirmed",
        payment_status: "paid"
      )
    end
    let!(:order_item) do
      order.order_items.create!(
        product: product,
        quantity: 1,
        price: 1000,
        subtotal: 1000,
        product_name: product.name
      )
    end
    let(:mail) { OrderMailer.confirmation(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Order Confirmation - #{order.order_number}")
      expect(mail.to).to eq([ "customer@example.com" ])
      expect(mail.from).to eq([ "no-reply@duka.rubycommunity.africa" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Order Confirmation: #{order.order_number}")
      expect(mail.body.encoded).to match("Thank you for your order!")
      expect(mail.body.encoded).to match("Test Product")
      expect(mail.body.encoded).to match(number_to_currency(1000, unit: "KES "))
    end
  end
end
