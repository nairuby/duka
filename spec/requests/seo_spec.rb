# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SEO and Search Digital Presence", type: :request do
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

  describe "Homepage SEO (GET /)" do
    before { get root_path }

    it "includes optimized page title" do
      expect(response.body).to include("<title>ARC Duka – African Ruby Community Shop | Official Merchandise</title>")
    end

    it "includes meta description" do
      expect(response.body).to include(%(name="description"))
      expect(response.body).to include("Official merchandise store for the African Ruby Community")
    end

    it "includes canonical link and index robots tag" do
      expect(response.body).to include(%(rel="canonical"))
      expect(response.body).to include(%(name="robots" content="index, follow))
    end

    it "embeds Organization and WebSite JSON-LD schemas" do
      expect(response.body).to include(%("OnlineStore"))
      expect(response.body).to include(%("WebSite"))
      expect(response.body).to include(%("SearchAction"))
    end
  end

  describe "Catalog SEO (GET /products)" do
    before { get products_path }

    it "includes optimized products catalog title and description" do
      expect(response.body).to include("<title>All Products | ARC Duka – African Ruby Community Shop</title>")
      expect(response.body).to include(%(name="description"))
    end

    it "embeds BreadcrumbList and ItemList JSON-LD schemas" do
      expect(response.body).to include(%("BreadcrumbList"))
      expect(response.body).to include(%("ItemList"))
    end
  end

  describe "Product Page SEO (GET /products/:id)" do
    before { get product_path(product) }

    it "includes product name in page title" do
      expect(response.body).to include("<title>Heritage Ruby Tee | ARC Duka – African Ruby Community Shop</title>")
    end

    it "embeds Product JSON-LD structured data with offers" do
      expect(response.body).to include(%("Product"))
      expect(response.body).to include(%("Heritage Ruby Tee"))
      expect(response.body).to include(%("African Ruby Community"))
      expect(response.body).to include(%("3500.00"))
      expect(response.body).to include(%("https://schema.org/InStock"))
    end

    it "embeds BreadcrumbList JSON-LD schema" do
      expect(response.body).to include(%("BreadcrumbList"))
    end
  end

  describe "Category Page SEO (GET /categories/:name)" do
    before { get category_path("Shirts") }

    it "includes category name in title and description" do
      expect(response.body).to include("<title>Shirts Collection | ARC Duka – African Ruby Community Shop</title>")
      expect(response.body).to include("Shop official African Ruby Community shirts")
    end

    it "embeds BreadcrumbList and ItemList JSON-LD schemas" do
      expect(response.body).to include(%("BreadcrumbList"))
      expect(response.body).to include(%("ItemList"))
    end
  end

  describe "Static Pages SEO" do
    it "renders About Us SEO metadata" do
      get landing_about_path
      expect(response.body).to include("<title>About Us | ARC Duka – African Ruby Community Shop</title>")
      expect(response.body).to include(%(name="description"))
      expect(response.body).to include(%("BreadcrumbList"))
    end

    it "renders Contact Us SEO metadata" do
      get new_contact_message_path
      expect(response.body).to include("<title>Contact Us | ARC Duka – African Ruby Community Shop</title>")
      expect(response.body).to include(%(name="description"))
      expect(response.body).to include(%("BreadcrumbList"))
    end
  end

  describe "Cart and Checkout Robot Directives" do
    it "sets noindex, nofollow on cart" do
      get cart_path
      expect(response.body).to include(%(name="robots" content="noindex, nofollow"))
    end

    it "sets noindex, nofollow on checkout" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 1 }
      get new_checkout_path
      expect(response.body).to include(%(name="robots" content="noindex, nofollow"))
    end
  end
end
