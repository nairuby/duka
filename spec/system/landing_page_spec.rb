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

      expect(page).to have_button("Shop Collection")
      expect(page).to have_button("Join Community")
    end
  end

  describe "Categories Section" do
    it "displays category grid" do
      visit root_path

      expect(page).to have_content("Shop by Category")
    end

    it "shows all product categories" do
      visit root_path

      expect(page).to have_content("Apparel")
      expect(page).to have_content("Drinkware")
      expect(page).to have_content("Accessories")
      expect(page).to have_content("Limited Edition")
    end

    it "has category icons" do
      visit root_path

      expect(page).to have_css("i.fa-tshirt")
      expect(page).to have_css("i.fa-mug-hot")
      expect(page).to have_css("i.fa-bookmark")
      expect(page).to have_css("i.fa-gem")
    end
  end

  describe "Products Section" do
    it "displays products heading" do
      visit root_path

      expect(page).to have_content("All Products")
    end

    it "shows product cards" do
      visit root_path

      expect(page).to have_content("Space Black Coffee Mug")
      expect(page).to have_content("Pearl White Coffee Mug")
      expect(page).to have_content("Black T-Shirt")
      expect(page).to have_content("White T-Shirt")
      expect(page).to have_content("Heritage Hoodie")
      expect(page).to have_content("Developer Notebook")
    end

    it "displays product prices" do
      visit root_path

      expect(page).to have_content("$18")
      expect(page).to have_content("$25")
      expect(page).to have_content("$45")
      expect(page).to have_content("$15")
    end

    it "has add to cart buttons" do
      visit root_path

      expect(page).to have_button("Add to Cart", count: 6)
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
        expect(page).to have_content("in Africa")
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
