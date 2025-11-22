class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :layout_by_resource
  helper_method :current_cart

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def current_cart
    session[:cart_id] ||= SecureRandom.uuid
    @current_cart ||= CartService.new(session[:cart_id])
  end
end
