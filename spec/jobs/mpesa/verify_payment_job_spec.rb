require 'rails_helper'

RSpec.describe Mpesa::VerifyPaymentJob, type: :job do
  let!(:order) do
    Order.create!(
      email: "verify_#{SecureRandom.hex(4)}@example.com",
      phone: "254712345678",
      status: "pending",
      payment_status: "started",
      total: 1000.0,
      subtotal: 1000.0,
      shipping_cost: 0.0,
      shipping_name: "Verify Test",
      shipping_address: "123 Test St",
      shipping_city: "Nairobi",
      shipping_country: "Kenya",
      currency: "KES",
      order_number: "ORD-#{SecureRandom.hex(4).upcase}",
      quikk_request_id: "ws_CO_191220191020363925"
    )
  end

  let(:daraja_client) { instance_double(Daraja::Client) }

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(Daraja::Client).to receive(:new).and_return(daraja_client)
  end

  it "does nothing if the callback already resolved the order" do
    order.update!(payment_status: "paid")

    expect(Daraja::Client).not_to receive(:new)
    described_class.perform_now(order.id)
  end

  it "marks the order paid when the query reports success" do
    allow(daraja_client).to receive(:stk_query).with("ws_CO_191220191020363925").and_return(
      "ResultCode" => 0, "ResultDesc" => "The service request is processed successfully."
    )

    described_class.perform_now(order.id)

    expect(order.reload.payment_status).to eq("paid")
    expect(order.payment_transactions.find_by(transaction_type: "query").status).to eq("success")
  end

  it "marks the order failed on a terminal ResultCode" do
    allow(daraja_client).to receive(:stk_query).and_return(
      "ResultCode" => 1032, "ResultDesc" => "Request cancelled by user"
    )

    described_class.perform_now(order.id)

    expect(order.reload.payment_status).to eq("failed")
  end

  it "retries when Safaricom hasn't settled the transaction yet" do
    allow(daraja_client).to receive(:stk_query).and_return(
      "errorCode" => "500.001.1001", "errorMessage" => "The transaction is being processed"
    )

    expect {
      described_class.perform_now(order.id, 1)
    }.to have_enqueued_job(described_class).with(order.id, 2)

    expect(order.reload.payment_status).to eq("started")
  end

  it "gives up after MAX_ATTEMPTS without changing the order" do
    allow(daraja_client).to receive(:stk_query).and_return(
      "errorCode" => "500.001.1001", "errorMessage" => "The transaction is being processed"
    )

    expect {
      described_class.perform_now(order.id, Mpesa::VerifyPaymentJob::MAX_ATTEMPTS)
    }.not_to have_enqueued_job(described_class)

    expect(order.reload.payment_status).to eq("started")
  end
end
