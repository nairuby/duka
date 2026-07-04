require 'rails_helper'

RSpec.describe "Checkouts", type: :request do
  let(:order) do
    Order.create!(
      email: "cod@example.com",
      phone: "0712345678",
      shipping_name: "COD User",
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

  before do
    # Mock session
    post "/checkouts", params: { order: { email: order.email } } # This is just to satisfy any session needs if they existed, but we'll manually set session in the test if needed. 
    # Actually, we can just set the session directly in the request if using some gems, but in plain RSpec request specs we can't easily.
    # However, process_payment uses session[:pending_order_id]
  end

  describe "POST /checkout/process_payment" do
    it "enqueues a confirmation email for cash on delivery" do
      # We need to simulate the session. In request specs, we can use a workaround or just call the controller action if it was a controller spec.
      # Since it's a request spec, we'll try to set the session by visiting the payment page first if it sets it.
      
      # Let's try to bypass the session by mocking Order.find in the controller if possible, 
      # but request specs should be end-to-end.
      
      # Another way:
      allow_any_instance_of(CheckoutsController).to receive(:session).and_return({ pending_order_id: order.id })
      
      ActiveJob::Base.queue_adapter = :test
      expect {
        post "/checkout/process_payment", params: { payment_method: "cash_on_delivery" }
      }.to have_enqueued_mail(OrderMailer, :confirmation).with(order)

      expect(response).to redirect_to(order_confirmation_path(order))
      order.reload
      expect(order.status).to eq("confirmed")
      expect(order.payment_method).to eq("cash_on_delivery")
    end
  end
end
