class HomeController < ApplicationController
  def index
    # About us page
    def about; end
    # Get products grouped by category (limit 4 per category for preview)
    @categories_with_products = Product::CATEGORIES.map do |category|
      products = Product.where(category: category).limit(4)
      { name: category, products: products } if products.any?
    end.compact

    # Get featured product for hero section (first product or create a default)
    @featured_product = Product.first || Product.new(
      name: "Heritage Ruby Tee",
      description: "Limited Edition • African Inspired Design",
      price: 3500.00,
      currency: "KES",
      category: "Shirts"
    )

    @cart = []
  end
end
