# frozen_string_literal: true

require "rails_helper"

RSpec.describe SeoHelper, type: :helper do
  before do
    allow(helper).to receive(:request).and_return(
      ActionDispatch::TestRequest.create("HTTP_HOST" => "duka.nairuby.org", "PATH_INFO" => "/products")
    )
  end

  describe "#meta_title" do
    it "returns default site title when no title is provided" do
      expect(helper.meta_title).to eq("ARC Duka – African Ruby Community Shop | Official Merchandise")
    end

    it "formats title with site brand suffix" do
      expect(helper.meta_title("Heritage Hoodie")).to eq("Heritage Hoodie | ARC Duka – African Ruby Community Shop")
    end

    it "does not duplicate brand name if already present" do
      expect(helper.meta_title("ARC Duka")).to eq("ARC Duka")
      expect(helper.meta_title("Shirts | ARC Duka")).to eq("Shirts | ARC Duka")
    end
  end

  describe "#meta_description" do
    it "returns default description when none is provided" do
      expect(helper.meta_description).to include("Official merchandise store for the African Ruby Community")
    end

    it "returns custom description when supplied" do
      expect(helper.meta_description("Custom description text.")).to eq("Custom description text.")
    end
  end

  describe "#meta_robots" do
    it "returns index, follow by default" do
      expect(helper.meta_robots).to include("index, follow")
    end

    it "honors content_for(:robots) override" do
      helper.content_for(:robots, "noindex, nofollow")
      expect(helper.meta_robots).to eq("noindex, nofollow")
    end
  end

  describe "#canonical_url" do
    it "returns clean base url and path without query parameters" do
      expect(helper.canonical_url).to eq("http://duka.nairuby.org/products")
    end

    it "honors content_for(:canonical_url) override" do
      helper.content_for(:canonical_url, "https://duka.nairuby.org/custom-path")
      expect(helper.canonical_url).to eq("https://duka.nairuby.org/custom-path")
    end
  end

  describe "#seo_meta_tags" do
    it "renders meta description, robots, canonical link, author, and theme-color" do
      rendered = helper.seo_meta_tags

      expect(rendered).to include(%(name="description"))
      expect(rendered).to include(%(name="robots" content="index, follow))
      expect(rendered).to include(%(rel="canonical" href="http://duka.nairuby.org/products"))
      expect(rendered).to include(%(name="author" content="African Ruby Community"))
      expect(rendered).to include(%(name="theme-color" content="#dc2626"))
    end
  end

  describe "#organization_json_ld" do
    it "returns valid Schema.org OnlineStore data with social media links" do
      data = helper.organization_json_ld

      expect(data[:@type]).to eq("OnlineStore")
      expect(data[:name]).to eq("ARC Duka")
      expect(data[:sameAs]).to include("https://x.com/ruby_african")
      expect(data[:sameAs]).to include("https://github.com/nairuby")
      expect(data[:contactPoint][:email]).to eq("info@rubycommunity.africa")
    end
  end

  describe "#website_json_ld" do
    it "returns valid Schema.org WebSite data with SearchAction" do
      data = helper.website_json_ld

      expect(data[:@type]).to eq("WebSite")
      expect(data[:potentialAction][:@type]).to eq("SearchAction")
      expect(data[:potentialAction][:target][:urlTemplate]).to include("/products?q={search_term_string}")
    end
  end

  describe "#breadcrumb_json_ld" do
    it "formats breadcrumb items into Schema.org BreadcrumbList" do
      items = [
        { name: "Home", url: "https://duka.nairuby.org/" },
        { name: "Products", url: "https://duka.nairuby.org/products" }
      ]

      data = helper.breadcrumb_json_ld(items)

      expect(data[:@type]).to eq("BreadcrumbList")
      expect(data[:itemListElement].length).to eq(2)
      expect(data[:itemListElement].first[:position]).to eq(1)
      expect(data[:itemListElement].first[:name]).to eq("Home")
      expect(data[:itemListElement].last[:position]).to eq(2)
      expect(data[:itemListElement].last[:name]).to eq("Products")
    end
  end

  describe "#product_json_ld" do
    it "generates Schema.org Product markup with Offer details" do
      product = Product.new(
        id: SecureRandom.uuid,
        name: "ARC Dev Tee",
        description: "Official community t-shirt",
        price: 2500.0,
        currency: "KES",
        category: "Shirts",
        image_url: "https://example.com/tee.jpg"
      )

      allow(helper).to receive(:product_url).with(product).and_return("https://duka.nairuby.org/products/#{product.id}")

      data = helper.product_json_ld(product)

      expect(data[:@type]).to eq("Product")
      expect(data[:name]).to eq("ARC Dev Tee")
      expect(data[:brand][:name]).to eq("African Ruby Community")
      expect(data[:offers][:@type]).to eq("Offer")
      expect(data[:offers][:price]).to eq("2500.00")
      expect(data[:offers][:priceCurrency]).to eq("KES")
      expect(data[:offers][:availability]).to eq("https://schema.org/InStock")
    end
  end
end
