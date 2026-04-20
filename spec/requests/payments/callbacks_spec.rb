require 'rails_helper'

RSpec.describe "Payments::Callbacks", type: :request do
  let(:order) { create(:order, quikk_request_id: 'test_req_123', payment_status: 'started') }
  let(:api_secret) { 'test_secret' }

  before do
    allow(ENV).to receive(:[]).with('QUIKK_API_SECRET').and_return(api_secret)
  end

  describe "POST /payments/quikk_callback" do
    let(:payload) do
      {
        request_id: 'test_req_123',
        status: 'SUCCESS',
        amount: 1000,
        phonenumber: '254712345678',
        mpesa_receipt: 'RKL591HJK',
        message: 'Success'
      }
    end
    let(:body) { payload.to_json }
    let(:signature) { OpenSSL::HMAC.hexdigest('SHA256', api_secret, body) }

    it "updates the order and payment transaction on success" do
      post "/payments/quikk_callback", params: body, headers: { 'X-Quikk-Signature' => signature, 'CONTENT_TYPE' => 'application/json' }
      
      expect(response).to have_http_status(:ok)
      order.reload
      expect(order.payment_status).to eq('paid')
      expect(order.mpesa_receipt).to eq('RKL591HJK')
      expect(order.status).to eq('confirmed')
      
      transaction = order.payment_transactions.find_by(transaction_type: 'callback')
      expect(transaction.status).to eq('success')
    end

    it "returns unauthorized for invalid signature" do
      post "/payments/quikk_callback", params: body, headers: { 'X-Quikk-Signature' => 'invalid', 'CONTENT_TYPE' => 'application/json' }
      
      expect(response).to have_http_status(:unauthorized)
      order.reload
      expect(order.payment_status).to eq('started')
    end

    it "handles duplicate callbacks gracefully" do
      order.update!(payment_status: 'paid')
      
      post "/payments/quikk_callback", params: body, headers: { 'X-Quikk-Signature' => signature, 'CONTENT_TYPE' => 'application/json' }
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Already processed')
    end
  end
end
