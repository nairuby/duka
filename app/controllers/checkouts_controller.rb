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

    if @order.payment_method == "mpesa" && (@order.payment_status == "pending" || @order.payment_status == "started")
      return redirect_to mpesa_status_checkout_path(id: @order.id), alert: "A payment is already in progress for this order."
    end

    case payment_method
    when "card"
      # Redirect to card payment (Stripe/PayPal - to be implemented)
      redirect_to card_payment_path(@order), notice: "Redirecting to card payment..."
      # when "bank_transfer"
      # Show bank transfer instructions
      # @order.update(payment_method: "bank_transfer")
      # redirect_to bank_transfer_instructions_path(@order)
    when "cash_on_delivery"
      # Mark as cash on delivery
      @order.update(payment_method: "cash_on_delivery", status: "confirmed")
      clear_cart
      redirect_to order_confirmation_path(@order), notice: "Order confirmed! Pay on delivery."
    when "mpesa"
      initiate_mpesa_payment
    else
      redirect_to payment_checkout_path, alert: "Please select a valid payment method."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Order not found. Please try again."
  end

  def mpesa_status
    @order = Order.find(params[:id])
    @payment = @order.payment_transactions.by_type("stk_push").recent.first

    # Commented out: search API timeout check (not configured yet)
    # if params[:timeout] == "true" && @order.payment_status == "started"
    #   # Trigger search API check
    #   quikk = Quikk::Client.new
    #   response = quikk.search(@order.quikk_request_id)
    #   attributes = response.dig("data", "attributes") || {}
    #   txn_status = response.dig("data", "attributes", "txn_status")
    #   receipt = attributes("mpesa_receipt") || attributes("receipt")
    #
    #   if txn_status == "SUCCESS" || txn_status == "SUCCESSFUL"
    #     @order.update!(
    #       payment_status: "paid",
    #       status: "confirmed",
    #       mpesa_receipt: receipt,
    #       payment_completed_at: Time.current
    #     )
    #   elsif txn_status == "FAILED"
    #     @order.update!(payment_status: "failed")
    #   else
    #     @order.update!(payment_status: "timed_out")
    #   end
    # end

    respond_to do |format|
      format.html
      format.json { render json: { status: @order.payment_status, payment_status: @payment&.status } }
    end
  end

  def confirmation
    @order = Order.find(params[:id])
    # Clear cart for any terminal payment state, not just "paid"
    if @order.payment_status == "paid" || @order.payment_method == "cash_on_delivery"
      clear_cart
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Order not found."
  end

  private

  def initiate_mpesa_payment
    phone = params[:mpesa_phone]
    if phone.blank?
      return redirect_to payment_checkout_path, alert: "Please provide an M-Pesa phone number."
    end

    # Create payment transaction
    payment = @order.payment_transactions.create!(
      transaction_type: "stk_push",
      status: "started",
      amount: @order.total,
      phone_number: phone
    )

    quikk = Quikk::Client.new
    response = quikk.charge(
      amount: @order.total,
      phone_number: phone,
      reference: "ORDER-#{@order.id}",
      description: "Payment for Order #{@order.order_number}"
    )

    request_id = response.dig("data", "id")
    if request_id.present?
      payment.update!(
        status: "pending",
        external_reference: request_id,
        raw_response: response
      )
      @order.update!(
        payment_method: "mpesa",
        payment_status: "started",
        payment_initiated_at: Time.current,
        quikk_request_id: request_id
      )
      Mpesa::VerifyPaymentJob.perform_later(@order.id)
      redirect_to mpesa_status_checkout_path(id: @order.id)
    else
      payment.update!(status: "failed", raw_response: response, error_message: response["error"] || response["message"])
      redirect_to payment_checkout_path, alert: "M-Pesa payment failed to initiate: #{response['message'] || 'Unknown error'}"
    end
  rescue => e
    Rails.logger.error("M-Pesa Initiation Error: #{e.message}")
    redirect_to payment_checkout_path, alert: "An error occurred while initiating M-Pesa payment."
  end

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
