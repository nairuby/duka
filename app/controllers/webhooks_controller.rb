class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def quikk
    body = request.raw_post

    # Skip signature verification in development/ sandbox

    unless Rails.env.production?
      Rails.logger.info("Skipping Quikk Signature verification in #{Rails.env}")
    else
      signature = request.headers['X-Quikk-Signature']
      quikk_client = Quikk::Client.new
      unless quikk_client.verify_signature(body, signature)
        Rails.logger.warn("Invalid Quikk Signature from IP: #{request.remote_ip}")
        return render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    payload = JSON.parse(body)

    # Log the full payload so we can see the structure
    Rails.logger.info("Quikk Webhook Payload: #{payload.inspect}")

    request_id = payload.dig('data', 'id')
    attributes = payload.dig('data', 'attributes') || {}
    txn_status = attributes['txn_status']

    order = Order.find_by(quikk_request_id: request_id)

    if order.nil?
      Rails.logger.error("Order not found for Quikk request_id: #{request_id}")
      return render json: { message: "Order not found" }, status: :not_found
    end

    return render json: { message: "Already processed" }, status: :ok if order.payment_status == 'paid'

    order.with_lock do
      return render json: { message: "Already processed" }, status: :ok if order.payment_status == 'paid'

      order.payment_transactions.create!(
        transaction_type: "callback",
        status: txn_status == 'SUCCESS' ? 'success' : 'failed',
        amount: attributes['amount'],
        phone_number: attributes['customer_no'],
        external_reference: request_id,
        raw_response: payload,
        error_message: attributes['message']
      )

      if txn_status == 'SUCCESS'
        order.update!(
          payment_status: 'paid',
          status: 'confirmed',
          mpesa_receipt: attributes['mpesa_receipt'] || attributes['receipt'],
          payment_completed_at: Time.current
        )
      else
        order.update!(payment_status: 'failed')
      end
    end

    render json: { message: "OK" }, status: :ok
  end
end
