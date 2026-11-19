# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentTransaction, type: :model do
  let(:order) do
    Order.create!(
      email: "payer@example.com",
      phone: "0712345678",
      shipping_name: "Payer",
      shipping_address: "123 Way",
      shipping_city: "Nairobi",
      shipping_postal_code: "00100",
      shipping_country: "Kenya",
      subtotal: 1000.0,
      total: 1000.0,
      status: "pending",
      payment_status: "pending"
    )
  end

  describe "validations" do
    it "is valid with required attributes" do
      tx = PaymentTransaction.new(
        order: order,
        transaction_type: "stk_push",
        status: "initiated",
        amount: 1000.0,
        phone_number: "0712345678"
      )
      expect(tx).to be_valid
    end

    it "validates inclusion of transaction_type" do
      tx = PaymentTransaction.new(order: order, transaction_type: "bitcoin", status: "pending")
      expect(tx).not_to be_valid
      expect(tx.errors[:transaction_type]).to be_present
    end

    it "validates inclusion of status" do
      tx = PaymentTransaction.new(order: order, transaction_type: "stk_push", status: "unknown")
      expect(tx).not_to be_valid
      expect(tx.errors[:status]).to be_present
    end

    it "requires positive amount for stk_push" do
      tx = PaymentTransaction.new(
        order: order,
        transaction_type: "stk_push",
        status: "initiated",
        phone_number: "0712345678",
        amount: 0
      )
      expect(tx).not_to be_valid
      expect(tx.errors[:amount]).to be_present
    end
  end

  describe "phone normalization and status helpers" do
    it "normalizes phone number to E.164 (+254...) format on validation" do
      tx = PaymentTransaction.create!(
        order: order,
        transaction_type: "stk_push",
        status: "initiated",
        amount: 500.0,
        phone_number: "0712345678"
      )
      expect(tx.phone_number).to eq("+254712345678")
    end

    it "provides status predicate methods" do
      tx = PaymentTransaction.new(order: order, transaction_type: "stk_push", status: "completed")
      expect(tx.successful?).to be(true)
      expect(tx.failed?).to be(false)
      expect(tx.pending?).to be(false)
      expect(tx.stk_push?).to be(true)
      expect(tx.callback?).to be(false)
    end

    it "sets processed_at when status changes to completed" do
      tx = PaymentTransaction.create!(
        order: order,
        transaction_type: "stk_push",
        status: "initiated",
        amount: 500.0,
        phone_number: "0712345678"
      )
      expect(tx.processed_at).to be_nil

      tx.update!(status: "completed")
      expect(tx.processed_at).to be_present
    end
  end

  describe "scopes" do
    it "filters transactions by type and status" do
      stk = PaymentTransaction.create!(order: order, transaction_type: "stk_push", status: "pending", amount: 100, phone_number: "0712345678")
      cb = PaymentTransaction.create!(order: order, transaction_type: "callback", status: "completed")

      expect(PaymentTransaction.by_type("stk_push")).to include(stk)
      expect(PaymentTransaction.by_type("stk_push")).not_to include(cb)
      expect(PaymentTransaction.by_status("completed")).to include(cb)
    end
  end
end
