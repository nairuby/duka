# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories", type: :request do
  let!(:shirt) { Product.create!(name: "Ruby Heritage Shirt", price: 2500, currency: "KES", category: "Shirts") }
  let!(:mug) { Product.create!(name: "Ruby Coffee Mug", price: 1200, currency: "KES", category: "Mugs") }

  describe "GET /categories" do
    it "returns HTTP success and renders categories list" do
      get categories_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Shop by Category")
      expect(response.body).to include("Shirts")
      expect(response.body).to include("Mugs")
    end
  end

  describe "GET /categories/:name" do
    it "returns HTTP success and displays products under the selected category" do
      get category_path("Shirts")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Ruby Heritage Shirt")
      expect(response.body).not_to include("Ruby Coffee Mug")
    end

    it "renders gracefully when category has no products" do
      get category_path("Accessories")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Accessories")
      expect(response.body).to include("No products found")
    end
  end
end
