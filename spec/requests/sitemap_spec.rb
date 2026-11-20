# frozen_string_literal: true

require "rails_helper"

RSpec.describe "XML Sitemap", type: :request do
  let!(:product) do
    Product.create!(
      name: "Heritage Ruby Tee",
      description: "Premium African Ruby Community merchandise",
      price: 3500.00,
      currency: "KES",
      category: "Shirts",
      image_url: "https://example.com/tee.jpg"
    )
  end

  describe "GET /sitemap.xml" do
    before { get "/sitemap.xml" }

    it "returns HTTP success" do
      expect(response).to have_http_status(:success)
    end

    it "sets application/xml content type" do
      expect(response.content_type).to include("application/xml")
    end

    it "sets public cache-control headers" do
      expect(response.headers["Cache-Control"]).to include("public")
      expect(response.headers["Cache-Control"]).to include("max-age=3600")
    end

    it "contains the sitemap schema namespaces" do
      expect(response.body).to include("http://www.sitemaps.org/schemas/sitemap/0.9")
      expect(response.body).to include("http://www.google.com/schemas/sitemap-image/1.1")
    end

    it "includes key canonical URLs" do
      expect(response.body).to include("<loc>http://www.example.com/</loc>")
      expect(response.body).to include("<loc>http://www.example.com/products</loc>")
      expect(response.body).to include("<loc>http://www.example.com/categories</loc>")
      expect(response.body).to include("<loc>http://www.example.com/about_us</loc>")
      expect(response.body).to include("<loc>http://www.example.com/contact</loc>")
      expect(response.body).to include("<loc>http://www.example.com/categories/Shirts</loc>")
      expect(response.body).to include("<loc>http://www.example.com/products/#{product.id}</loc>")
    end

    it "includes image metadata for products" do
      expect(response.body).to include("<image:loc>https://example.com/tee.jpg</image:loc>")
      expect(response.body).to include("<image:title>Heritage Ruby Tee</image:title>")
    end
  end
end
