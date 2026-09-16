class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Daraja's STK callback. Like Quikk, Safaricom does not sign this request —
  # the endpoint is protected the same way: only a callback that resolves to
  # an order we actually initiated (via CheckoutRequestID) can touch anything.
  def mpesa
    body = JSON.parse(request.raw_post.presence || "{}")
    callback = body.dig("Body", "stkCallback") || {}
    checkout_request_id = callback["CheckoutRequestID"]

    Rails.logger.info("Daraja Webhook Payload: #{callback.inspect}")

    order = checkout_request_id.present? ? Order.find_by(quikk_request_id: checkout_request_id) : nil

    if order.nil?
      Rails.logger.error("Order not found for Daraja callback: CheckoutRequestID=#{checkout_request_id}")
      return render json: { message: "Order not found" }, status: :not_found
    end

    return render json: { message: "Already processed" }, status: :ok if order.payment_status == "paid"

    result_code = callback["ResultCode"]
    metadata = extract_metadata(callback)
    succeeded = result_code.to_s == "0"

    order.with_lock do
      return render json: { message: "Already processed" }, status: :ok if order.payment_status == "paid"

      order.payment_transactions.create!(
        transaction_type: "callback",
        status: succeeded ? "success" : "failed",
        amount: metadata["Amount"].presence || order.total,
        phone_number: metadata["PhoneNumber"].present? ? metadata["PhoneNumber"].to_s : order.phone,
        external_reference: checkout_request_id,
        raw_response: body,
        error_message: callback["ResultDesc"]
      )

      if succeeded
        order.mark_as_paid!(metadata["MpesaReceiptNumber"])
      else
        order.update!(payment_status: "failed")
      end
    end

    render json: { message: "OK" }, status: :ok
  rescue JSON::ParserError
    Rails.logger.warn("Unparseable Daraja callback body from IP: #{request.remote_ip}")
    render json: { error: "Bad Request" }, status: :bad_request
  end

  private

  def extract_metadata(callback)
    items = callback.dig("CallbackMetadata", "Item") || []
    items.each_with_object({}) { |item, hash| hash[item["Name"]] = item["Value"] }
  end
end
