class HomeController < ApplicationController
  def index
    # Get products grouped by category (limit 4 per category for preview)
    @categories_with_products = Product::CATEGORIES.map do |category|
      products = Product.where(category: category).limit(4)
      { name: category, products: products } if products.any?
    end.compact

    # Get featured product for hero section (first product or create a default)
    @featured_product = Product.first || Product.new(
      name: "Heritage Ruby Tee",
      description: "Limited Edition • African Inspired Design",
      price: 29.00,
      currency: "USD",
      category: "Shirts"
    )

    @cart = []
  end
end
