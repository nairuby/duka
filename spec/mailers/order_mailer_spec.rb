require "rails_helper"

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
        total: 1100,
        status: "confirmed",
        payment_status: "paid"
      )
    end
    let!(:order_item) do
      order.order_items.create!(
        product: product,
        quantity: 2,
        price: 500,
        subtotal: 1000,
        product_name: product.name
      )
    end

    let(:mailer) { OrderMailer.new }

    before do
      allow(mailer).to receive(:send_via_brevo)
    end

    it "calls send_via_brevo with the order" do
      mailer.confirmation(order)
      expect(mailer).to have_received(:send_via_brevo).with(order)
    end

    describe "#template_params" do
      subject(:params) { mailer.send(:template_params, order) }

      it "includes order metadata" do
        expect(params[:order_number]).to eq(order.order_number)
        expect(params[:customer_name]).to eq("Jane Doe")
        expect(params[:currency]).to eq(order.currency)
        expect(params[:subtotal]).to eq(order.subtotal.to_s)
        expect(params[:total]).to eq(order.total.to_s)
      end

      it "includes shipping address" do
        expect(params[:address_line_1]).to eq("123 Street")
        expect(params[:city]).to eq("Nairobi")
        expect(params[:country]).to eq("Kenya")
      end

      it "maps order items to the items array" do
        expect(params[:items].length).to eq(1)
        expect(params[:items].first[:product_name]).to eq("Test Product")
        expect(params[:items].first[:quantity]).to eq(2)
        expect(params[:items].first[:subtotal]).to eq(order_item.subtotal.to_s)
      end

      it "builds the correct subject line" do
        expect("Your order ##{params[:order_number]} is confirmed ✓")
          .to eq("Your order ##{order.order_number} is confirmed ✓")
      end
    end
  end
end
