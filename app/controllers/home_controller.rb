class HomeController < ApplicationController
  def index
    @products = []
    @categories = []
    @cart = []
  end
end
