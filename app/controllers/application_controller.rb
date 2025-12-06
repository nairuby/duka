class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :layout_by_resource
  helper_method :current_cart

  before_action :set_current_attributes

  private

  def set_current_attributes
    Current.user = current_user if defined?(current_user)
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip

    # Location detection
    # In development/test, typically 127.0.0.1 which geocoder might not resolve well without configuration
    # We default strictly to Kenya as requested if detection fails or returns nil/reserved.
    results = Geocoder.search(request.ip)
    result = results.first

    if result&.country_code.present? && result.country_code != "RD" # RD is Reserved
      Current.country_code = result.country_code
      Current.location = result
    else
      Current.country_code = "KE"
    end

    # Currency logic
    # Default to KES for everyone essentially unless we have specific logic
    # The requirement is "default to kenya", so we make KES the primary.
    # If we wanted to support others, we'd map country_code to currency here.
    Current.currency = session[:currency] || "KES"
  end

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
