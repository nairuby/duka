module Mpesa
  class ChargeJob < ApplicationJob
    queue_as :default

    def perform(order_id, phone)
      order = Order.find(order_id)
      
      # Create payment transaction
      payment = order.payment_transactions.create!(
        transaction_type: "stk_push",
        status: "started",
        amount: order.total,
        phone_number: phone
      )

      quikk = Quikk::Client.new
      response = quikk.charge(
        amount: order.total,
        phone_number: phone,
        reference: "ORDER-#{order.id}",
        description: "Payment for Order #{order.order_number}"
      )

      request_id = response.dig("data", "id")
      if request_id.present?
        payment.update!(
          status: "pending",
          external_reference: request_id,
          raw_response: response
        )
        order.update!(
          payment_method: "mpesa",
          payment_status: "started",
          payment_initiated_at: Time.current,
          quikk_request_id: request_id
        )
        Mpesa::VerifyPaymentJob.perform_later(order.id)
      else
        payment.update!(status: "failed", raw_response: response, error_message: response["error"] || response["message"])
        order.update!(payment_status: "failed")
      end
    rescue => e
      Rails.logger.error("M-Pesa ChargeJob Error for Order #{order_id}: #{e.message}")
      order.update!(payment_status: "failed") if defined?(order) && order
    end
  end
end
