class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :initialize_cart
  helper_method :current_cart

  private

  def initialize_cart
    session[:cart_id] ||= SecureRandom.uuid
  end

  def current_cart
    @current_cart ||= CartService.new(session[:cart_id])
  end
end
