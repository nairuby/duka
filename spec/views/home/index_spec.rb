# frozen_string_literal: true

require "rails_helper"

RSpec.describe "home/index", type: :view do
  before do
    # Create test products for the view
    @products = [
      double("Product",
             name: "Test Product 1",
             description: "Test description",
             price: 29.99,
             currency: "USD",
             image_url: "https://via.placeholder.com/400x400",
             id: "test-id-1",
             category: "Shirts",
             persisted?: true
      ),
      double("Product",
             name: "Test Product 2",
             description: "Test description",
             price: 19.99,
             currency: "USD",
             image_url: "https://via.placeholder.com/400x400",
             id: "test-id-2",
             category: "Mugs",
             persisted?: true
      )
    ]
    assign(:products, @products)

    # Mock categories with products for the landing page partial
    @categories_with_products = [
      { name: "Shirts", products: [ @products[0] ] },
      { name: "Mugs", products: [ @products[1] ] }
    ]
    assign(:categories_with_products, @categories_with_products)

    # Mock featured product for hero section
    @featured_product = @products[0]
    assign(:featured_product, @featured_product)

    # Mock current_cart helper with actual CartService
    def view.current_cart
      @current_cart ||= CartService.new("test-session-id")
    end
  end

  it "includes all landing page sections" do
    render

    # Check for navbar
    expect(rendered).to have_css("nav")

    # Check for hero section
    expect(rendered).to match(/Wear Your/)

    # Check for products section
    expect(rendered).to match(/All Products/)

    # Check for footer
    expect(rendered).to have_css("footer")
  end
end
