class ProductsController < ApplicationController
  before_action :set_product, only: [ :show ]

  def index
    @products = Product.all

    if params[:q].present?
      query = "%#{params[:q].to_s.strip.downcase}%"
      @products = @products.where("LOWER(name) LIKE :q OR LOWER(description) LIKE :q OR LOWER(category) LIKE :q", q: query)
    end

    if params[:category].present?
      @products = @products.by_category(params[:category])
    end
  end

  def show
    @variants = @product.variants.includes(:product)
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end
