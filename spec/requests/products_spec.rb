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

    it "explains why adding to cart requires a variant selection" do
      Variant.create!(product: product, size: "M", color: "Red", stock_quantity: 5, sku: "CART-001")

      get "/products/#{product.id}"

      page = Nokogiri::HTML(response.body)
      button = page.at_css('[data-product-detail-target="addToCartBtn"]')
      help = page.at_css('#add-to-cart-help')
      expect(button["disabled"]).not_to be_nil
      expect(button["aria-describedby"]).to eq(help["id"])
      expect(help["role"]).to eq("status")
      expect(help.text).to include("Choose a size and color to add this item to your cart.")
    end

    it "allows adding a product without variants without selection guidance" do
      get "/products/#{product.id}"

      page = Nokogiri::HTML(response.body)
      button = page.at_css('input[type="submit"][value="Add to Cart"]')
      expect(button["disabled"]).to be_nil
      expect(page.at_css('#add-to-cart-help')).to be_nil
    end

    it "includes Open Graph tags pointing at the product image" do
      product.update!(image_url: "https://example.com/tee.jpg")

      get "/products/#{product.id}"

      expect(response.body).to include(%(property="og:title" content="Test Product"))
      expect(response.body).to include(%(property="og:image" content="https://example.com/tee.jpg"))
      expect(response.body).to include(%(property="og:type" content="product"))
    end

    it "falls back to the site logo for Open Graph image when the product has none" do
      product.update!(image_url: nil)

      get "/products/#{product.id}"

      expect(response.body).to match(%r{property="og:image" content="https?://[^"]*arc_logo_coloured})
    end
  end
end
