require 'rails_helper'

RSpec.describe "Payments::MpesaCallback", type: :request do
  let!(:order) do
    Order.create!(
      email: "mpesa_callback_#{SecureRandom.hex(4)}@example.com",
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
      quikk_request_id: "ws_CO_191220191020363925"
    )
  end

  let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

  describe "POST /payments/mpesa/callback" do
    let(:success_payload) do
      {
        Body: {
          stkCallback: {
            MerchantRequestID: "29115-34620561-1",
            CheckoutRequestID: "ws_CO_191220191020363925",
            ResultCode: 0,
            ResultDesc: "The service request is processed successfully.",
            CallbackMetadata: {
              Item: [
                { Name: "Amount", Value: 1000.0 },
                { Name: "MpesaReceiptNumber", Value: "NLJ7RT61SV" },
                { Name: "TransactionDate", Value: 20260914102115 },
                { Name: "PhoneNumber", Value: 254712345678 }
              ]
            }
          }
        }
      }
    end

    it "marks the order paid and records the callback" do
      post "/payments/mpesa/callback", params: success_payload.to_json, headers: json_headers

      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.payment_status).to eq('paid')
      expect(order.mpesa_receipt).to eq('NLJ7RT61SV')
      expect(order.status).to eq('confirmed')

      transaction = order.payment_transactions.find_by(transaction_type: 'callback')
      expect(transaction.status).to eq('success')
      expect(transaction.amount).to eq(1000.0)
    end

    it "marks the order failed on a non-zero ResultCode" do
      failure_payload = {
        Body: {
          stkCallback: {
            MerchantRequestID: "29115-34620561-1",
            CheckoutRequestID: "ws_CO_191220191020363925",
            ResultCode: 1032,
            ResultDesc: "Request cancelled by user"
          }
        }
      }

      post "/payments/mpesa/callback", params: failure_payload.to_json, headers: json_headers

      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.payment_status).to eq('failed')

      transaction = order.payment_transactions.find_by(transaction_type: 'callback')
      expect(transaction.status).to eq('failed')
      expect(transaction.error_message).to eq('Request cancelled by user')
    end

    it "returns 404 for a callback that maps to no known order" do
      payload = success_payload.deep_dup
      payload[:Body][:stkCallback][:CheckoutRequestID] = "ws_CO_unknown"

      post "/payments/mpesa/callback", params: payload.to_json, headers: json_headers

      expect(response).to have_http_status(:not_found)
    end

    it "handles duplicate callbacks gracefully" do
      order.update!(payment_status: 'paid')

      post "/payments/mpesa/callback", params: success_payload.to_json, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Already processed')
    end
  end
end
