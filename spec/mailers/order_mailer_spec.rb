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

    before do
      allow_any_instance_of(OrderMailer).to receive(:send_via_brevo)
    end

    it "calls send_via_brevo with the order" do
      expect_any_instance_of(OrderMailer).to receive(:send_via_brevo).with(order)
      OrderMailer.confirmation(order)
    end

    describe "#template_params" do
      subject(:params) { OrderMailer.new.send(:template_params, order) }

      it "includes order metadata" do
        expect(params[:order_number]).to eq(order.order_number)
        expect(params[:customer_name]).to eq("Jane Doe")
        expect(params[:currency]).to eq(order.currency)
        expect(params[:subtotal]).to eq("1000")
        expect(params[:total]).to eq("1100")
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
        expect(params[:items].first[:subtotal]).to eq("1000")
      end
    end
  end
end
