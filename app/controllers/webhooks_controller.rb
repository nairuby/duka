class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def quikk
    body = request.raw_post

    # Skip signature verification in development/ sandbox

    unless Rails.env.production?
      Rails.logger.info("Skipping Quikk Signature verification in #{Rails.env}")
    else
      signature = request.headers["X-Quikk-Signature"]
      quikk_client = Quikk::Client.new
      unless quikk_client.verify_signature(body, signature)
        Rails.logger.warn("Invalid Quikk Signature from IP: #{request.remote_ip}")
        Rails.logger.debug("Incoming Signature: #{signature}")
        # Rails.logger.debug("Body: #{body}") # Be careful with PII
        return render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    payload = JSON.parse(body)

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
