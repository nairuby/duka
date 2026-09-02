require 'rails_helper'

RSpec.describe "Payments::Callbacks", type: :request do
  let!(:order) do
    Order.create!(
      email: "callback_#{SecureRandom.hex(4)}@example.com",
      phone: "254712345678",
      status: "pending",
      payment_status: "started",
      total: 1000.0,
      subtotal: 1000.0,
      shipping_cost: 0.0,
      shipping_name: "Callback Test",
      shipping_address: "123 Test St",
      shipping_city: "Nairobi",
      shipping_country: "Kenya",
      currency: "KES",
      order_number: "ORD-#{SecureRandom.hex(4).upcase}",
      quikk_request_id: "ORDER-#{SecureRandom.uuid}"
    )
  end

  let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

  describe "POST /payments/callback" do
    # Quikk's real success callback omits txn_status; the M-Pesa receipt is txn_id.
    let(:payload) do
      {
        data: {
          type: "payin",
          id: order.quikk_request_id,
          attributes: {
            txn_id: "RKL591HJK",
            sender_no: "254712345678",
            amount: 1000,
            txn_charge_id: "ws_CO_27072017151044001"
          }
        }
      }
    end
    let(:body) { payload.to_json }

    it "marks the order paid, records the callback, and enqueues the confirmation email" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        post "/payments/callback", params: body, headers: json_headers
      }.to have_enqueued_mail(OrderMailer, :confirmation)

      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.payment_status).to eq('paid')
      expect(order.mpesa_receipt).to eq('RKL591HJK')
      expect(order.status).to eq('confirmed')

      transaction = order.payment_transactions.find_by(transaction_type: 'callback')
      expect(transaction.status).to eq('success')
    end

    it "accepts the callback without any signature header" do
      post "/payments/callback", params: body, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.payment_status).to eq('paid')
    end

    it "matches the order by ORDER-<uuid> id when quikk_request_id is unset" do
      order.update!(quikk_request_id: nil)
      payload[:data][:id] = "ORDER-#{order.id}"

      post "/payments/callback", params: payload.to_json, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.payment_status).to eq('paid')
    end

    it "marks the order failed when the callback reports a failure" do
      failure = {
        data: { type: "payin", id: order.quikk_request_id, attributes: { txn_charge_id: "AG_123" } },
        meta: { status: "FAIL", code: "1029", detail: "Request cancelled by user" }
      }

      post "/payments/callback", params: failure.to_json, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(order.reload.payment_status).to eq('failed')

      transaction = order.payment_transactions.find_by(transaction_type: 'callback')
      expect(transaction.status).to eq('failed')
      expect(transaction.error_message).to eq('Request cancelled by user')
    end

    it "returns 404 for a callback that maps to no known order" do
      payload[:data][:id] = "ORDER-#{SecureRandom.uuid}"

      post "/payments/callback", params: payload.to_json, headers: json_headers

      expect(response).to have_http_status(:not_found)
    end

    it "handles duplicate callbacks gracefully" do
      order.update!(payment_status: 'paid')

      post "/payments/callback", params: body, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Already processed')
    end
  end
end
