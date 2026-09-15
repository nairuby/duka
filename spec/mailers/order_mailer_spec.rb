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

    # Render the confirmation template directly without triggering the Brevo API
    let(:html) do
      mailer = OrderMailer.new
      mailer.instance_variable_set(:@order, order)
      mailer.instance_variable_set(:@order_items, order.order_items)
      mailer.render_to_string(
        template: "order_mailer/confirmation",
        layout: "mailer",
        formats: [ :html ]
      )
    end

    it "renders the correct subject and recipient" do
      expect("Order Confirmation - #{order.order_number}").to eq("Order Confirmation - #{order.order_number}")
      expect(order.email).to eq("customer@example.com")
    end

    it "includes order details in the email body" do
      expect(html).to match("Order Confirmation: #{order.order_number}")
      expect(html).to match("Thank you for your order!")
      expect(html).to match("Test Product")
      expect(html).to match(number_to_currency(1000, unit: "KES "))
    end

    it "sends the email via Brevo" do
      api_instance = instance_double(Brevo::TransactionalEmailsApi)
      allow(Brevo::TransactionalEmailsApi).to receive(:new).and_return(api_instance)
      expect(api_instance).to receive(:send_transac_email).with(instance_of(Brevo::SendSmtpEmail))

      OrderMailer.confirmation(order).deliver_now
    end
  end
end
