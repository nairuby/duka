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

      daraja = Daraja::Client.new
      response = daraja.stk_push(
        amount: order.total,
        phone_number: phone,
        reference: order.order_number,
        description: "Payment for Order #{order.order_number}"
      )

      checkout_request_id = response["CheckoutRequestID"]
      if response["ResponseCode"].to_s == "0" && checkout_request_id.present?
        payment.update!(
          status: "pending",
          external_reference: checkout_request_id,
          raw_response: response
        )
        # NOTE: quikk_request_id is the generic provider-request correlator used
        # by both Quikk and Daraja (renaming it is a bigger migration than this
        # cutover warrants) — it now holds Daraja's CheckoutRequestID.
        order.update!(
          payment_method: "mpesa",
          payment_status: "started",
          payment_initiated_at: Time.current,
          quikk_request_id: checkout_request_id
        )
        # Give the customer time to see the prompt and enter their PIN before
        # polling Safaricom — this is the reconciliation fallback for a lost
        # callback, not the primary path.
        Mpesa::VerifyPaymentJob.set(wait: 20.seconds).perform_later(order.id)
      else
        payment.update!(
          status: "failed",
          raw_response: response,
          error_message: response["errorMessage"] || response["CustomerMessage"]
        )
        order.update!(payment_status: "failed")
      end
    rescue => e
      Rails.logger.error("M-Pesa ChargeJob Error for Order #{order_id}: #{e.message}")
      order.update!(payment_status: "failed") if defined?(order) && order
    end
  end
end
