module Payments
  class CallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def quikk
      body = request.raw_post
      signature = request.headers['X-Quikk-Signature']
      
      quikk = Quikk::Client.new
      unless quikk.verify_signature(body, signature)
        Rails.logger.warn("Invalid Quikk Signature from IP: #{request.remote_ip}")
        return render json: { error: "Unauthorized" }, status: :unauthorized
      end

      payload = JSON.parse(body)
      request_id = payload['request_id']
      
      order = Order.find_by(quikk_request_id: request_id)
      
      if order.nil?
        Rails.logger.error("Order not found for Quikk request_id: #{request_id}")
        return render json: { message: "Order not found" }, status: :not_found
      end

      # Handle duplicate callbacks
      if order.payment_status == 'paid'
        return render json: { message: "Already processed" }, status: :ok
      end

      # Create callback transaction record
      order.payment_transactions.create!(
        transaction_type: "callback",
        status: payload['status'] == 'SUCCESS' ? 'success' : 'failed',
        amount: payload['amount'],
        phone_number: payload['phonenumber'],
        external_reference: request_id,
        raw_response: payload,
        error_message: payload['message']
      )

      if payload['status'] == 'SUCCESS'
        order.update!(
          payment_status: 'paid',
          status: 'confirmed',
          mpesa_receipt: payload['mpesa_receipt'],
          payment_completed_at: Time.current
        )
      else
        order.update!(payment_status: 'failed')
      end

      render json: { message: "OK" }, status: :ok
    end
  end
end
