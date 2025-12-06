require 'rails_helper'

RSpec.describe "Orders Show", type: :request do
  let(:user) { User.create!(email: "test_#{SecureRandom.hex}@example.com", password: "password", password_confirmation: "password") }
  let(:order) {
    Order.create!(
      user: user,
      email: user.email,
      status: "confirmed",
      payment_status: "paid",
      total: 100.0,
      subtotal: 90.0,
      shipping_cost: 10.0,
      shipping_name: "Test User",
      shipping_address: "123 Test St",
      shipping_city: "Nairobi",
      shipping_country: "Kenya",
      phone: "1234567890",
      currency: "KES",
      order_number: "ORD-#{SecureRandom.hex(4).upcase}"
    )
  }

  before do
    sign_in user
  end

  it "renders the show template successfully" do
    get order_path(order)
    expect(response).to be_successful
    expect(response.body).to include("Order Confirmed!")
  end
end
