# app/jobs/mpesa/verify_payment_job.rb
module Mpesa
  # Reconciliation fallback: polls Daraja's STK Push Query endpoint in case the
  # callback to /payments/mpesa/callback never arrives (server briefly down,
  # network blip, etc). The callback is still the primary/fast path — this
  # only acts on orders still stuck at "started".
  class VerifyPaymentJob < ApplicationJob
    queue_as :default

    MAX_ATTEMPTS = 6 # ~2 minutes of polling at 20s apart before giving up

    def perform(order_id, attempt = 1)
      order = Order.find(order_id)
      return unless order.payment_status == "started" # callback already resolved it

      response = Daraja::Client.new.stk_query(order.quikk_request_id)
      result_code = response["ResultCode"]

      if result_code.nil?
        # No ResultCode means Safaricom hasn't settled the transaction yet
        # (typically an errorCode like "500.001.1001 - transaction is being
        # processed"), not a real error — keep waiting.
        return retry_or_give_up(order_id, attempt)
      end

      record_query_transaction(order, response, result_code)

      order.with_lock do
        next unless order.payment_status == "started"

        if result_code.to_s == "0"
          order.mark_as_paid!(nil) # STK Query never returns the receipt; the callback fills it in if it later arrives
        else
          order.update!(payment_status: "failed")
        end
      end
    rescue ActiveRecord::RecordNotFound
      # order was removed; nothing to reconcile
    end

    private

    def retry_or_give_up(order_id, attempt)
      if attempt < MAX_ATTEMPTS
        self.class.set(wait: 20.seconds).perform_later(order_id, attempt + 1)
      else
        Rails.logger.warn("Mpesa::VerifyPaymentJob: gave up reconciling order #{order_id} after #{MAX_ATTEMPTS} query attempts")
      end
    end

    def record_query_transaction(order, response, result_code)
      order.payment_transactions.create!(
        transaction_type: "query",
        status: result_code.to_s == "0" ? "success" : "failed",
        amount: order.total,
        phone_number: order.phone,
        external_reference: order.quikk_request_id,
        raw_response: response,
        error_message: response["ResultDesc"]
      )
    end
  end
end
