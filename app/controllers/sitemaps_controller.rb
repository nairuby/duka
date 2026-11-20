# frozen_string_literal: true

class SitemapsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def index
    @categories = Product::CATEGORIES
    @products = Product.all.order(updated_at: :desc)

    respond_to do |format|
      format.xml do
        response.headers["Content-Type"] = "application/xml; charset=utf-8"
        response.headers["Cache-Control"] = "public, max-age=3600"
        render layout: false
      end
    end
  end
end
