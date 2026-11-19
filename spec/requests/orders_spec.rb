# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:user) { User.create!(email: "customer_#{SecureRandom.hex(4)}@example.com", password: "password123") }
  let(:other_user) { User.create!(email: "other_#{SecureRandom.hex(4)}@example.com", password: "password123") }
  let(:admin) { User.create!(email: "admin_#{SecureRandom.hex(4)}@example.com", password: "password123", admin: true) }

  let(:order) do
    Order.create!(
      user: user,
      email: user.email,
      phone: "0712345678",
      shipping_name: "Customer Name",
      shipping_address: "123 Street",
      shipping_city: "Nairobi",
      shipping_postal_code: "00100",
      shipping_country: "Kenya",
      subtotal: 2000.0,
      total: 2000.0,
      status: "confirmed",
      payment_status: "paid"
    )
  end

  describe "GET /orders (index)" do
    it "redirects unauthenticated users to sign in" do
      get orders_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders the orders list when user is authenticated" do
      sign_in user
      get orders_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /orders/:id (show)" do
    it "allows the order owner to view the order" do
      sign_in user
      get order_path(order)
      expect(response).to be_successful
      expect(response.body).to include("Order Confirmed!")
    end

    it "allows an admin to view any order" do
      sign_in admin
      get order_path(order)
      expect(response).to be_successful
    end

    it "redirects other authenticated users with an alert" do
      sign_in other_user
      get order_path(order)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to include("don't have permission")
    end

    it "redirects unauthenticated users with an alert" do
      get order_path(order)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to include("don't have permission")
    end

    it "handles missing order gracefully" do
      sign_in user
      get order_path(SecureRandom.uuid)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to include("Order not found")
    end
  end
end
