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
      quikk_request_id: "test_req_123"
    )
  end
  let(:api_secret) { 'test_secret' }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('QUIKK_API_SECRET').and_return(api_secret)
  end

  describe "POST /payments/callback" do
    let(:payload) do
      {
        data: {
          id: "test_req_123",
          attributes: {
            txn_status: "SUCCESS",
            amount: 1000,
            customer_no: "254712345678",
            mpesa_receipt: "RKL591HJK",
            message: "Success"
          }
        }
      }
    end
    let(:body) { payload.to_json }
    let(:signature) { OpenSSL::HMAC.hexdigest('SHA256', api_secret, body) }

    it "updates the order and payment transaction on success and enqueues confirmation email" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        post "/payments/callback", params: body, headers: { 'X-Quikk-Signature' => signature, 'CONTENT_TYPE' => 'application/json' }
      }.to have_enqueued_mail(OrderMailer, :confirmation)

      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.payment_status).to eq('paid')
      expect(order.mpesa_receipt).to eq('RKL591HJK')
      expect(order.status).to eq('confirmed')

      transaction = order.payment_transactions.find_by(transaction_type: 'callback')
      expect(transaction.status).to eq('success')
    end

    it "accepts callbacks in non-production even with invalid signature" do
      post "/payments/callback", params: body, headers: { 'X-Quikk-Signature' => 'invalid', 'CONTENT_TYPE' => 'application/json' }

      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.payment_status).to eq('paid')
    end

    it "handles duplicate callbacks gracefully" do
      order.update!(payment_status: 'paid')

      post "/payments/callback", params: body, headers: { 'X-Quikk-Signature' => signature, 'CONTENT_TYPE' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Already processed')
    end
  end
end
