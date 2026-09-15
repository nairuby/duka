require 'rails_helper'

RSpec.describe Mpesa::ChargeJob, type: :job do
  let!(:order) do
    Order.create!(
      email: "charge_#{SecureRandom.hex(4)}@example.com",
      phone: "254712345678",
      status: "pending",
      payment_status: "pending",
      total: 1000.0,
      subtotal: 1000.0,
      shipping_cost: 0.0,
      shipping_name: "Charge Test",
      shipping_address: "123 Test St",
      shipping_city: "Nairobi",
      shipping_country: "Kenya",
      currency: "KES",
      order_number: "ORD-#{SecureRandom.hex(4).upcase}"
    )
  end

  let(:daraja_client) { instance_double(Daraja::Client) }

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(Daraja::Client).to receive(:new).and_return(daraja_client)
  end

  context "when the STK push is accepted" do
    let(:success_response) do
      {
        "MerchantRequestID" => "29115-34620561-1",
        "CheckoutRequestID" => "ws_CO_191220191020363925",
        "ResponseCode" => "0",
        "ResponseDescription" => "Success. Request accepted for processing",
        "CustomerMessage" => "Success. Request accepted for processing"
      }
    end

    before { allow(daraja_client).to receive(:stk_push).and_return(success_response) }

    it "marks the order as started, stores the CheckoutRequestID, and schedules reconciliation" do
      expect {
        described_class.perform_now(order.id, "0712345678")
      }.to have_enqueued_job(Mpesa::VerifyPaymentJob).with(order.id)

      order.reload
      expect(order.payment_method).to eq("mpesa")
      expect(order.payment_status).to eq("started")
      expect(order.quikk_request_id).to eq("ws_CO_191220191020363925")

      payment = order.payment_transactions.find_by(transaction_type: "stk_push")
      expect(payment.status).to eq("pending")
      expect(payment.external_reference).to eq("ws_CO_191220191020363925")
    end
  end

  context "when the STK push is rejected" do
    let(:failure_response) do
      {
        "ResponseCode" => "1",
        "errorMessage" => "Invalid PartyB"
      }
    end

    before { allow(daraja_client).to receive(:stk_push).and_return(failure_response) }

    it "marks the order and payment transaction as failed" do
      described_class.perform_now(order.id, "0712345678")

      order.reload
      expect(order.payment_status).to eq("failed")

      payment = order.payment_transactions.find_by(transaction_type: "stk_push")
      expect(payment.status).to eq("failed")
      expect(payment.error_message).to eq("Invalid PartyB")
    end
  end

  context "when Daraja::Client raises" do
    before { allow(daraja_client).to receive(:stk_push).and_raise(Faraday::TimeoutError) }

    it "marks the order as failed instead of leaving it stuck" do
      described_class.perform_now(order.id, "0712345678")

      expect(order.reload.payment_status).to eq("failed")
    end
  end
end
