# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Avo Admin Endpoints", type: :request do
  let(:admin) { User.create!(email: "admin_#{SecureRandom.hex(4)}@example.com", password: "password123", admin: true) }
  let(:regular_user) { User.create!(email: "user_#{SecureRandom.hex(4)}@example.com", password: "password123", admin: false) }

  context "as an admin user" do
    before do
      sign_in admin
    end

    it "renders the products index resource" do
      get "/avo/resources/products"
      expect(response).to have_http_status(:success)
    end

    it "renders the orders index resource" do
      get "/avo/resources/orders"
      expect(response).to have_http_status(:success)
    end

    it "renders the users index resource" do
      get "/avo/resources/users"
      expect(response).to have_http_status(:success)
    end

    it "renders the variants index resource" do
      get "/avo/resources/variants"
      expect(response).to have_http_status(:success)
    end

    it "renders the order items index resource" do
      get "/avo/resources/order_items"
      expect(response).to have_http_status(:success)
    end

    it "renders the payment transactions index resource" do
      get "/avo/resources/payment_transactions"
      expect(response).to have_http_status(:success)
    end

    it "renders the contact messages index resource" do
      get "/avo/resources/contact_messages"
      expect(response).to have_http_status(:success)
    end
  end

  context "as a regular non-admin user" do
    it "denies access and redirects to root" do
      sign_in regular_user
      get "/avo/resources/products"
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to include("Admin privileges required")
    end
  end

  context "as an unauthenticated visitor" do
    it "redirects to login" do
      get "/avo/resources/products"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
