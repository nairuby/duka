require 'rails_helper'

RSpec.describe "Cart Cleanup", type: :request do
  let!(:product) { Product.create!(name: "Test Product", price: 1000, currency: "KES", category: "Shirts") }
  let(:session_id) { SecureRandom.uuid }

  before do
    # Add item to cart
    CartItem.create!(session_id: session_id, product: product, quantity: 1)
  end

  describe "Cash on Delivery checkout" do
    it "clears the cart after successful payment processing" do
      # Mock session cart_id and pending_order_id
      order = Order.create!(
        email: "test@example.com",
        phone: "0712345678",
        shipping_name: "Test User",
        shipping_address: "123 Street",
        shipping_city: "Nairobi",
        shipping_postal_code: "00100",
        shipping_country: "Kenya",
        subtotal: 1000,
        total: 1000,
        status: "pending",
        payment_status: "pending",
        session_token: session_id
      )

      allow_any_instance_of(CheckoutsController).to receive(:session).and_return({
        cart_id: session_id,
        pending_order_id: order.id
      })

      expect(CartItem.where(session_id: session_id).count).to eq(1)

      post "/checkout/process_payment", params: { payment_method: "cash_on_delivery" }

      expect(response).to redirect_to(order_confirmation_path(order))
      expect(CartItem.where(session_id: session_id).count).to eq(0)
    end
  end

  describe "M-Pesa Webhook" do
    it "clears the cart after successful payment notification" do
      order = Order.create!(
        email: "test@example.com",
        phone: "0712345678",
        shipping_name: "Test User",
        shipping_address: "123 Street",
        shipping_city: "Nairobi",
        shipping_postal_code: "00100",
        shipping_country: "Kenya",
        subtotal: 1000,
        total: 1000,
        status: "pending",
        payment_status: "pending",
        session_token: session_id,
        quikk_request_id: "REQ-123"
      )

      expect(CartItem.where(session_id: session_id).count).to eq(1)

      webhook_payload = {
        data: {
          id: "REQ-123",
          attributes: {
            txn_status: "SUCCESS",
            amount: 1000,
            customer_no: "254712345678",
            mpesa_receipt: "ABC123DEF",
            txn_id: "TXN-456"
          }
        }
      }

      post "/payments/callback", params: webhook_payload.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.payment_status).to eq("paid")
      expect(CartItem.where(session_id: session_id).count).to eq(0)
    end
  end
end
