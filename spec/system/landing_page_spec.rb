# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Landing Page", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "Navbar" do
    it "displays the African Ruby branding" do
      visit root_path

      expect(page).to have_content("African Ruby")
      expect(page).to have_content("Community Store")
    end

    it "has navigation links" do
      visit root_path

      expect(page).to have_link("About Us")
      expect(page).to have_link("Community")
      expect(page).to have_link("Contact")
    end

    it "displays shopping cart icon" do
      visit root_path

      expect(page).to have_css("i.fa-shopping-cart")
    end

    it "displays search icon" do
      visit root_path

      expect(page).to have_css("i.fa-search")
    end
  end

  describe "Hero Section" do
    it "displays the main headline" do
      visit root_path

      expect(page).to have_content("Wear Your")
      expect(page).to have_content("Ruby")
      expect(page).to have_content("Pride")
    end

    it "displays the description" do
      visit root_path

      expect(page).to have_content("Celebrate African excellence in tech")
    end

    it "has call-to-action buttons" do
      visit root_path

      expect(page).to have_link("Shop Collection")
      expect(page).to have_link("Join Community")
    end
  end

  describe "Categories Section" do
    it "displays category grid" do
      visit root_path

      expect(page).to have_content("Explore All Products")
    end

    it "shows all product categories" do
      visit root_path

      expect(page).to have_content("Shirts")
      expect(page).to have_content("Mugs")
      expect(page).to have_content("Accessories")
      expect(page).to have_content("Stickers")
    end

    it "has category icons" do
      visit root_path

      expect(page).to have_css("i.fa-tshirt")
      expect(page).to have_css("i.fa-mug-hot")
      expect(page).to have_css("i.fa-gift")
      expect(page).to have_css("i.fa-note-sticky")
    end
  end

  describe "Products Section" do
    before do
      # Create test products for system tests
      Product.create!(name: "Premium Cotton T-Shirt", description: "Test", price: 29.99, currency: "USD", category: "Shirts")
      Product.create!(name: "Ruby Coffee Mug", description: "Test", price: 18.99, currency: "USD", category: "Mugs")
    end

    it "displays products heading" do
      visit root_path

      expect(page).to have_content("All Products")
    end

    it "shows product cards" do
      visit root_path

      expect(page).to have_content("Premium Cotton T-Shirt")
      expect(page).to have_content("Ruby Coffee Mug")
    end

    it "displays product prices" do
      visit root_path

      expect(page).to have_content("KES2,999")
      expect(page).to have_content("KES1,899")
    end

    it "has view details buttons" do
      visit root_path

      expect(page).to have_content("View")
    end
  end

  describe "Footer" do
    it "displays African Ruby branding" do
      visit root_path

      within("footer") do
        expect(page).to have_content("African Ruby")
      end
    end

    it "has footer navigation sections" do
      visit root_path

      within("footer") do
        expect(page).to have_content("Products")
        expect(page).to have_content("Community")
        expect(page).to have_content("Support")
      end
    end

    it "displays copyright information" do
      visit root_path

      within("footer") do
        expect(page).to have_content("African Ruby Community")
        expect(page).to have_content("Made with")
        expect(page).to have_content("by ARC")
      end
    end

    it "has social media links" do
      visit root_path

      within("footer") do
        # Check for Font Awesome social icons
        expect(page).to have_css("i.fab")
      end
    end
  end

  describe "Responsive Design" do
    it "has mobile menu button" do
      visit root_path

      expect(page).to have_css("#mobile-menu-button")
    end
  end
end
