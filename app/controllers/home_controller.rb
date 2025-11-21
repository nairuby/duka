class HomeController < ApplicationController
  def index
    # Get products grouped by category (limit 4 per category for preview)
    @categories_with_products = Product::CATEGORIES.map do |category|
      products = Product.where(category: category).limit(4)
      { name: category, products: products } if products.any?
    end.compact

    @cart = []
  end
end
