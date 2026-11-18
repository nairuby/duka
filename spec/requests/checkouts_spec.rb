# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Checkouts", type: :request do
  let(:product) { Product.create!(name: "Test Shirt", price: 1500.0, currency: "KES", category: "Shirts") }
  let(:session_id) { SecureRandom.uuid }
  let(:order) do
    Order.create!(
      email: "buyer@example.com",
      phone: "0712345678",
      shipping_name: "Buyer Name",
      shipping_address: "123 Street",
      shipping_city: "Nairobi",
      shipping_postal_code: "00100",
      shipping_country: "Kenya",
      subtotal: 1500.0,
      total: 1500.0,
      status: "pending",
      payment_status: "pending"
    )
  end

  describe "GET /checkout/new" do
    it "redirects to cart_path if the cart is empty" do
      get new_checkout_path
      expect(response).to redirect_to(cart_path)
      follow_redirect!
      expect(flash[:alert]).to include("Your cart is empty")
    end

    it "renders the checkout form when cart has items" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 1 }

      get new_checkout_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Checkout")
    end
  end

  describe "POST /checkout" do
    before do
      post add_item_cart_path, params: { product_id: product.id, quantity: 1 }
    end

    it "creates an order and redirects to payment" do
      valid_params = {
        order: {
          email: "buyer@example.com",
          phone: "0712345678",
          shipping_name: "John Doe",
          shipping_address: "456 Avenue",
          shipping_city: "Nairobi",
          shipping_postal_code: "00100",
          shipping_country: "Kenya"
        }
      }

      expect {
        post checkout_path, params: valid_params
      }.to change(Order, :count).by(1)

      expect(response).to redirect_to(payment_checkout_path)
    end

    it "renders :new with 422 if params are invalid" do
      invalid_params = {
        order: {
          email: "",
          shipping_name: ""
        }
      }

      expect {
        post checkout_path, params: invalid_params
      }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /checkout/payment" do
    it "renders payment selection when pending order exists in session" do
      allow_any_instance_of(CheckoutsController).to receive(:session).and_return({ pending_order_id: order.id })

      get payment_checkout_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Select Payment Method")
    end

    it "redirects to cart if pending order is not found" do
      allow_any_instance_of(CheckoutsController).to receive(:session).and_return({ pending_order_id: SecureRandom.uuid })

      get payment_checkout_path
      expect(response).to redirect_to(cart_path)
    end
  end

  describe "POST /checkout/process_payment" do
    before do
      allow_any_instance_of(CheckoutsController).to receive(:session).and_return({
        pending_order_id: order.id,
        cart_id: session_id
      })
    end

    it "enqueues a confirmation email and confirms order for cash on delivery" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        post "/checkout/process_payment", params: { payment_method: "cash_on_delivery" }
      }.to have_enqueued_mail(OrderMailer, :confirmation).with(order)

      expect(response).to redirect_to(order_confirmation_path(order))
      order.reload
      expect(order.status).to eq("confirmed")
      expect(order.payment_method).to eq("cash_on_delivery")
    end

    it "requires phone number for M-Pesa payments" do
      post "/checkout/process_payment", params: { payment_method: "mpesa", mpesa_phone: "" }

      expect(response).to redirect_to(payment_checkout_path)
      follow_redirect!
      expect(flash[:alert]).to include("Please provide an M-Pesa phone number")
    end

    it "initiates M-Pesa payment and enqueues ChargeJob" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        post "/checkout/process_payment", params: { payment_method: "mpesa", mpesa_phone: "0712345678" }
      }.to have_enqueued_job(Mpesa::ChargeJob).with(order.id, "0712345678")

      expect(response).to redirect_to(mpesa_status_checkout_path(id: order.id))
      order.reload
      expect(order.payment_method).to eq("mpesa")
      expect(order.payment_status).to eq("started")
    end

    it "redirects to status page if an M-Pesa payment is already in progress" do
      order.update!(payment_method: "mpesa", payment_status: "started", updated_at: 30.seconds.ago)

      post "/checkout/process_payment", params: { payment_method: "mpesa", mpesa_phone: "0712345678" }
      expect(response).to redirect_to(mpesa_status_checkout_path(id: order.id))
      follow_redirect!
      expect(flash[:alert]).to include("already in progress")
    end

    it "redirects back with alert for invalid payment methods" do
      post "/checkout/process_payment", params: { payment_method: "crypto" }

      expect(response).to redirect_to(payment_checkout_path)
      follow_redirect!
      expect(flash[:alert]).to include("Please select a valid payment method")
    end
  end

  describe "GET /checkout/mpesa_status/:id" do
    it "renders the status page HTML" do
      get mpesa_status_checkout_path(order.id)
      expect(response).to have_http_status(:success)
    end

    it "responds to JSON with order payment status" do
      get mpesa_status_checkout_path(order.id, format: :json)
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("pending")
    end
  end

  describe "GET /orders/:id/confirmation" do
    it "renders the order confirmation view" do
      get order_confirmation_path(order)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Order Confirmed!")
    end

    it "redirects to root if order does not exist" do
      get order_confirmation_path(SecureRandom.uuid)
      expect(response).to redirect_to(root_path)
    end
  end
end
