require 'rails_helper'

RSpec.describe "Products", type: :request do
  let!(:product) { Product.create!(name: "Test Product", description: "Test", price: 29.99, currency: "USD") }

  describe "GET /index" do
    it "returns http success" do
      get "/products"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/products/#{product.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
