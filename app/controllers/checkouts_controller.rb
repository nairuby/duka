class CheckoutsController < ApplicationController
  before_action :ensure_cart_not_empty, only: [ :new, :create ]

  def new
    @order = Order.new(
      email: current_user&.email,
      shipping_country: "Kenya",
      currency: "KES"
    )
  end

  def create
    @order = Order.create_from_cart(
      current_cart,
      current_user,
      checkout_params
    )

    if @order.persisted?
      # Store order ID in session for payment processing
      session[:pending_order_id] = @order.id

      # Redirect to payment selection
      redirect_to payment_checkout_path, notice: "Order created successfully. Please select payment method."
    else
      flash.now[:alert] = "There was an error creating your order."
      render :new, status: :unprocessable_entity
    end
  end

  def payment
    @order = Order.find(session[:pending_order_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Order not found. Please try again."
  end

  def process_payment
    @order = Order.find(session[:pending_order_id])
    payment_method = params[:payment_method]

    case payment_method
    when "mpesa"
      # Redirect to M-Pesa payment flow (to be implemented)
      redirect_to mpesa_payment_path(@order), notice: "Redirecting to M-Pesa payment..."
    when "card"
      # Redirect to card payment (Stripe/PayPal - to be implemented)
      redirect_to card_payment_path(@order), notice: "Redirecting to card payment..."
    when "bank_transfer"
      # Show bank transfer instructions
      @order.update(payment_method: "bank_transfer")
      redirect_to bank_transfer_instructions_path(@order)
    when "cash_on_delivery"
      # Mark as cash on delivery
      @order.update(payment_method: "cash_on_delivery", status: "confirmed")
      clear_cart
      redirect_to order_confirmation_path(@order), notice: "Order confirmed! Pay on delivery."
    else
      redirect_to payment_checkout_path, alert: "Please select a valid payment method."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Order not found. Please try again."
  end

  def confirmation
    @order = Order.find(params[:id])
    clear_cart if @order.payment_status == "paid" || @order.payment_method == "cash_on_delivery"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Order not found."
  end

  private

  def checkout_params
    params.require(:order).permit(
      :email,
      :phone,
      :shipping_name,
      :shipping_address,
      :shipping_city,
      :shipping_postal_code,
      :shipping_country,
      :notes
    )
  end

  def ensure_cart_not_empty
    if current_cart.empty?
      redirect_to cart_path, alert: "Your cart is empty. Add some products first!"
    end
  end

  def clear_cart
    session.delete(:cart)
    session.delete(:pending_order_id)
  end
end
