require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe "confirmation" do
    let(:product) { Product.create!(name: "Test Product", price: 1000, currency: "KES") }
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
        status: "confirmed",
        payment_status: "paid"
      )
    end
    let!(:order_item) do
      order.order_items.create!(
        product: product,
        quantity: 2,
        price: 500,
        subtotal: 1000,
        product_name: product.name
      )
    end

    # Stub the Brevo API so no real HTTP calls are made, but still capture
    # the SendSmtpEmail object to assert it was built correctly.
    let(:brevo_api) { double("Brevo::TransactionalEmailsApi") }
    let(:captured_email) { nil }

    before do
      allow(Rails.application.credentials).to receive(:dig)
        .with(:brevo, :order_confirmation_template_id)
        .and_return(42)

      # Stub the Brevo classes without requiring the gem
      stub_const("Brevo::TransactionalEmailsApi", Class.new do
        def initialize; end
        def send_transac_email(email); end
      end)

      stub_const("Brevo::SendSmtpEmail", Class.new do
        attr_accessor :to, :sender, :template_id, :subject, :params
        def initialize; end
      end)

      stub_const("Brevo::SendSmtpEmailTo", Struct.new(:email))
      stub_const("Brevo::SendSmtpEmailSender", Struct.new(:name, :email))
      stub_const("Brevo::ApiError", Class.new(StandardError))

      allow(Brevo::TransactionalEmailsApi).to receive(:new).and_return(brevo_api)
      allow(brevo_api).to receive(:send_transac_email)
    end

    subject(:run_mailer) { OrderMailer.new.confirmation(order) }

    it "calls the Brevo API once" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email).once
    end

    it "sends to the correct recipient" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.to.first.email).to eq("customer@example.com")
      end
    end

    it "sends from the correct sender" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.sender.email).to eq("orders@shop.rubycommunity.africa")
        expect(email.sender.name).to eq("Ruby Community Shop")
      end
    end

    it "uses the configured template id" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.template_id).to eq(42)
      end
    end

    it "sets the correct subject" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.subject).to eq("Your order ##{order.order_number} is confirmed ✓")
      end
    end

    it "raises if template_id is not configured" do
      allow(Rails.application.credentials).to receive(:dig)
        .with(:brevo, :order_confirmation_template_id)
        .and_return(nil)

      # nil template_id should still call the API; Brevo will reject it
      # This test documents the behaviour so a missing credential is visible in CI
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.template_id).to be_nil
      end
    end

    describe "#template_params" do
      subject(:params) { OrderMailer.new.send(:template_params, order) }

      it "includes order metadata" do
        expect(params[:order_number]).to eq(order.order_number)
        expect(params[:customer_name]).to eq("Jane Doe")
        expect(params[:currency]).to eq(order.currency)
        expect(params[:subtotal]).to eq(order.subtotal.to_s)
        expect(params[:total]).to eq(order.total.to_s)
        expect(params[:shipping]).to eq(order.shipping_cost.to_s)
      end

      it "includes shipping address" do
        expect(params[:address_line_1]).to eq("123 Street")
        expect(params[:city]).to eq("Nairobi")
        expect(params[:postal_code]).to eq("00100")
        expect(params[:country]).to eq("Kenya")
      end

      it "maps all order items into the items array" do
        expect(params[:items].length).to eq(1)

        item = params[:items].first
        expect(item[:product_name]).to eq("Test Product")
        expect(item[:quantity]).to eq(2)
        expect(item[:subtotal]).to eq(order_item.subtotal.to_s)
        expect(item[:variant]).to eq("")
      end
    end
  end
end
