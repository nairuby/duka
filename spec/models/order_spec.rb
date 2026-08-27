# == Schema Information
#
# Table name: orders
#
#  id                   :uuid             not null, primary key
#  billing_address      :jsonb
#  currency             :string           default("KES")
#  email                :string
#  mpesa_receipt        :string
#  notes                :text
#  order_number         :string
#  payment_completed_at :datetime
#  payment_initiated_at :datetime
#  payment_method       :string
#  payment_reference    :string
#  payment_status       :string           default("pending")
#  payment_timeout_at   :datetime
#  phone                :string
#  session_token        :string
#  shipping_address     :jsonb
#  shipping_city        :string
#  shipping_cost        :decimal(10, 2)   default(0.0)
#  shipping_country     :string           default("Kenya")
#  shipping_name        :string
#  shipping_postal_code :string
#  status               :string           default("cart"), not null
#  subtotal             :decimal(10, 2)
#  total                :decimal(10, 2)   default(0.0), not null
#  user_email           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  quikk_request_id     :string
#  user_id              :uuid
#
# Indexes
#
#  index_orders_on_email           (email)
#  index_orders_on_order_number    (order_number) UNIQUE
#  index_orders_on_payment_status  (payment_status)
#  index_orders_on_session_token   (session_token)
#  index_orders_on_status          (status)
#  index_orders_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "#mark_as_paid!" do
    let(:order) do
      Order.create!(
        email: "customer@example.com",
        phone: "0712345678",
        shipping_name: "Jane Doe",
        shipping_address: "123 Street",
        shipping_city: "Nairobi",
        shipping_postal_code: "00100",
        shipping_country: "Kenya",
        subtotal: 1000,
        total: 1000,
        status: "pending",
        payment_status: "pending"
      )
    end

    it "updates status to confirmed and payment_status to paid" do
      order.mark_as_paid!("REF123")
      expect(order.status).to eq("confirmed")
      expect(order.payment_status).to eq("paid")
      expect(order.mpesa_receipt).to eq("REF123")
      expect(order.payment_completed_at).to be_present
    end

    it "enqueues a confirmation email" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        order.mark_as_paid!("REF123")
      }.to have_enqueued_mail(OrderMailer, :confirmation).with(order)
    end
  end

  describe "#confirm!" do
    let(:order) do
      Order.create!(
        email: "customer@example.com",
        phone: "0712345678",
        shipping_name: "Jane Doe",
        shipping_address: "123 Street",
        shipping_city: "Nairobi",
        shipping_postal_code: "00100",
        shipping_country: "Kenya",
        subtotal: 1000,
        total: 1000,
        status: "pending",
        payment_status: "pending"
      )
    end

    it "updates status to confirmed and sets payment_completed_at" do
      order.confirm!
      expect(order.status).to eq("confirmed")
      expect(order.payment_completed_at).to be_present
    end

    it "enqueues a confirmation email" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        order.confirm!
      }.to have_enqueued_mail(OrderMailer, :confirmation).with(order)
    end
  end

  describe "payment method validation" do
    it "prevents new bank_transfer orders" do
      order = Order.new(payment_method: "bank_transfer")
      order.valid?(:create)
      expect(order.errors[:payment_method]).to include("Bank transfers are no longer supported")
    end

    it "allows existing bank_transfer orders to be saved" do
      # Bypass validation for creation to simulate existing record
      order = Order.new(
        email: "customer@example.com",
        phone: "0712345678",
        shipping_name: "Jane Doe",
        shipping_address: "123 Street",
        shipping_city: "Nairobi",
        shipping_postal_code: "00100",
        shipping_country: "Kenya",
        subtotal: 1000,
        total: 1000,
        status: "pending",
        payment_status: "pending",
        payment_method: "bank_transfer"
      )
      # Trigger order number generation which normally happens on create
      order.valid?
      order.save!(validate: false)

      order.status = "confirmed"
      expect(order.save).to be_truthy
      expect(order.reload.status).to eq("confirmed")
    end
  end
end
