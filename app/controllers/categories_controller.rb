class CategoriesController < ApplicationController
  def index
    @categories = Product.distinct.pluck(:category).compact.sort
  end

  def show
    @category_name = params[:name]
    @products = Product.where(category: @category_name)
  end
end
