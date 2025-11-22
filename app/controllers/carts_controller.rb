class CartsController < ApplicationController
  before_action :ensure_session_id
  before_action :set_cart

  def show
    @suggested_products = @cart.suggested_products
  end

  def add_item
    product = Product.find(params[:product_id])
    
    begin
      @cart.add_item(
        params[:product_id],
        variant_id: params[:variant_id].presence,
        quantity: params[:quantity]&.to_i || 1
      )

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("cart_preview_content", partial: "carts/preview_content", locals: { cart: @cart }),
            turbo_stream.replace("cart_count", partial: "shared/cart_count", locals: { count: @cart.total_items })
          ]
        end
        format.html do
          flash[:notice] = "#{product.name} added to cart"
          redirect_back fallback_location: root_path
        end
        format.json { render json: { success: true, cart_count: @cart.total_items, message: "Added to cart" } }
      end
    rescue => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("flash-messages", partial: "shared/flash_message", locals: { type: "alert", message: e.message })
        end
        format.html do
          flash[:alert] = e.message
          redirect_back fallback_location: root_path
        end
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
      end
    end
  end

  def update_quantity
    begin
      @cart.update_quantity(params[:id], params[:quantity].to_i)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("cart_preview_content", partial: "carts/preview_content", locals: { cart: @cart }),
            turbo_stream.replace("cart_count", partial: "shared/cart_count", locals: { count: @cart.total_items })
          ]
        end
        format.html { redirect_to cart_path }
        format.json { render json: { success: true, cart_count: @cart.total_items } }
      end
    rescue => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("cart_preview_content", partial: "carts/preview_content", locals: { cart: @cart }),
            turbo_stream.prepend("flash-container", partial: "shared/flash_alert", locals: { message: e.message })
          ]
        end
        format.html do
          flash[:alert] = e.message
          redirect_to cart_path
        end
        format.json { render json: { success: false, message: e.message }, status: :unprocessable_entity }
      end
    end
  end

  def remove_item
    @cart.remove_item(params[:id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("cart_preview_content", partial: "carts/preview_content", locals: { cart: @cart }),
          turbo_stream.replace("cart_count", partial: "shared/cart_count", locals: { count: @cart.total_items })
        ]
      end
      format.html { redirect_to cart_path, notice: "Item removed from cart" }
      format.json { render json: { success: true, cart_count: @cart.total_items } }
    end
  end

  def clear
    @cart.clear
    redirect_to root_path, notice: "Cart cleared"
  end

  private

  def ensure_session_id
    session[:cart_id] ||= SecureRandom.uuid
  end

  def set_cart
    @cart = CartService.new(session[:cart_id])
  end
end
