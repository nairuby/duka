require 'rails_helper'

RSpec.describe "Admin::Products", type: :request do
  let!(:product) { Product.create!(name: "Test Product", description: "Test", price: 29.99, currency: "USD") }

  describe "GET /index" do
    it "returns http success" do
      get "/admin/products"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/products/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a product" do
      post "/admin/products", params: { 
        product: { 
          name: "New Product", 
          description: "New description", 
          price: 39.99, 
          currency: "USD" 
        } 
      }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/products/#{product.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates the product" do
      patch "/admin/products/#{product.id}", params: { 
        product: { name: "Updated Product" } 
      }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /destroy" do
    it "deletes the product" do
      delete "/admin/products/#{product.id}"
      expect(response).to have_http_status(:redirect)
    end
  end
end
