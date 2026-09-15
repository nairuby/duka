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

  # Legacy Quikk path — kept for rollback; not wired up to checkout anymore
  # now that Mpesa::ChargeJob calls Daraja::Client directly.
  def quikk
    body = request.raw_post

    # Quikk does not sign the charge callback (no signature scheme is defined for
    # the `onData` callback in the Handaki API spec), so there is nothing to
    # verify here. The endpoint is protected instead by requiring the callback to
    # map to an order we actually initiated (see the lookup below); an unmatched
    # payload is rejected with 404 and never touches an order.
    payload = JSON.parse(body.presence || "{}")

    # Log the full payload so we can see the structure
    Rails.logger.info("Quikk Webhook Payload: #{payload.inspect}")

    request_id = payload.dig("data", "id")
    attributes = payload.dig("data", "attributes") || {}
    meta = payload["meta"] || {}
    txn_status = attributes["txn_status"].to_s.upcase
    resource_id = attributes["resource_id"].presence || attributes["txn_charge_id"].presence
    response_id = attributes["response_id"].presence

    # Callback id can be either Quikk request id or developer-provided id (e.g. ORDER-<uuid>)
    candidate_ids = [ request_id, resource_id, response_id ].compact_blank
    order = Order.where(quikk_request_id: candidate_ids).first

    if order.nil? && request_id.to_s.start_with?("ORDER-")
      possible_order_id = request_id.delete_prefix("ORDER-")
      order = Order.find_by(id: possible_order_id)
    end

    if order.nil?
      Rails.logger.error("Order not found for Quikk callback ids: request_id=#{request_id}, resource_id=#{resource_id}, response_id=#{response_id}")
      return render json: { message: "Order not found" }, status: :not_found
    end

    return render json: { message: "Already processed" }, status: :ok if order.payment_status == "paid"

    order.with_lock do
      return render json: { message: "Already processed" }, status: :ok if order.payment_status == "paid"

      succeeded = success_status?(txn_status, attributes, meta)

      # Failure callbacks routinely omit amount/customer_no, so fall back to the
      # order's own values to keep the audit record valid.
      order.payment_transactions.create!(
        transaction_type: "callback",
        status: succeeded ? "success" : "failed",
        amount: attributes["amount"].presence || order.total,
        phone_number: attributes["customer_no"].presence || attributes["sender_no"].presence || order.phone,
        external_reference: (resource_id || response_id || request_id),
        raw_response: payload,
        error_message: attributes["message"] || meta["detail"]
      )

      if succeeded
        order.mark_as_paid!(callback_receipt(attributes))
      else
        order.update!(payment_status: "failed")
      end
    end

    render json: { message: "OK" }, status: :ok
  rescue JSON::ParserError
    Rails.logger.warn("Unparseable Quikk callback body from IP: #{request.remote_ip}")
    render json: { error: "Bad Request" }, status: :bad_request
  end

  private

  def extract_metadata(callback)
    items = callback.dig("CallbackMetadata", "Item") || []
    items.each_with_object({}) { |item, hash| hash[item["Name"]] = item["Value"] }
  end

  def success_status?(txn_status, attributes, meta = {})
    return true if %w[SUCCESS SUCCESSFUL COMPLETED PAID].include?(txn_status)
    return false if %w[FAILED FAIL ERROR DECLINED CANCELLED CANCELED].include?(txn_status)
    return false if %w[FAIL FAILED ERROR].include?(meta["status"].to_s.upcase)

    # Quikk payin callbacks may omit txn_status; txn_id indicates a settled success callback.
    attributes["txn_id"].present?
  end

  # Quikk's success callback carries the M-Pesa receipt in `txn_id`; older/other
  # payloads may use `mpesa_receipt` or `receipt`.
  def callback_receipt(attributes)
    attributes["mpesa_receipt"].presence ||
      attributes["receipt"].presence ||
      attributes["txn_id"].presence
  end
end
