class HomeController < ApplicationController
  def index
    @products = Product.limit(6) # Show first 6 products on landing page
    @categories = []
    @cart = []
  end
end
