# app/jobs/mpesa/verify_payment_job.rb
module Mpesa
  class VerifyPaymentJob < ApplicationJob
    queue_as :default

    def perform(order_id, retry_count = 0)
      # Search API not configured yet - webhook handles confirmation
      # TODO: enable once serach API is set up on QUIKK dashboard
      # order = Order.find(order_id)
      #
      # # Exit if already paid or we've reached max retries (approx 3 mins)
      # return if order.payment_status == "paid" || retry_count > 6
      #
      # quikk = Quikk::Client.new
      # response = quikk.search(order.quikk_request_id)
      # attributes = response.dig("data", "attributes") || {}
      # txn_status = attributes["txn_status"]
      #
      # if txn_status == "SUCCESS" || txn_status == "SUCCESSFUL"
      #   order.with_lock do
      #     order.reload
      #     return if order.payment_status == "paid"
      #     order.update!(
      #       payment_status: "paid",
      #       status: "confirmed",
      #       mpesa_receipt: attributes["mpesa_receipt"] || attributes["receipt"]
      #     )
      #   end
      # elsif txn_status == "FAILED"
      #   order.update!(payment_status: "failed")
      # else
      #   # Re-queue job to check again in 30 seconds
      #   self.class.set(wait: 30.seconds).perform_later(order_id, retry_count + 1)
      # end
    end
  end
end
