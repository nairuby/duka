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

    it "includes variant image_url in the serialized variants JSON" do
      Variant.create!(
        product: product, size: "M", color: "Red", stock_quantity: 5, sku: "IMG-001",
        image_url: "https://example.com/variant-red.png"
      )

      get "/products/#{product.id}"

      expect(response.body).to include("https://example.com/variant-red.png")
    end
  end
end
