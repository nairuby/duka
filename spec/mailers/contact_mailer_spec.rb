require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  describe "new_message" do
    let(:contact_message) do
      ContactMessage.create!(
        name: "Jane Doe",
        email: "jane@example.com",
        subject: "Question about an order",
        message: "Hi, when will my order ship?"
      )
    end

    # Stub the Brevo API so no real HTTP calls are made, but still capture
    # the SendSmtpEmail object to assert it was built correctly. Mirrors
    # spec/mailers/order_mailer_spec.rb.
    let(:brevo_api) { double("Brevo::TransactionalEmailsApi") }

    before do
      stub_const("Brevo::TransactionalEmailsApi", Class.new do
        def initialize; end
        def send_transac_email(email); end
      end)

      stub_const("Brevo::SendSmtpEmail", Class.new do
        attr_accessor :to, :sender, :reply_to, :subject, :html_content
        def initialize; end
      end)

      stub_const("Brevo::SendSmtpEmailTo", Struct.new(:email))
      stub_const("Brevo::SendSmtpEmailSender", Struct.new(:name, :email))
      stub_const("Brevo::SendSmtpEmailReplyTo", Struct.new(:name, :email))
      stub_const("Brevo::ApiError", Class.new(StandardError))

      allow(Brevo::TransactionalEmailsApi).to receive(:new).and_return(brevo_api)
      allow(brevo_api).to receive(:send_transac_email)
    end

    subject(:run_mailer) { ContactMailer.new.new_message(contact_message) }

    it "calls the Brevo API once" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email).once
    end

    it "sends to the default recipient" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.to.first.email).to eq("info@rubycommunity.africa")
      end
    end

    it "sets reply_to to the person who submitted the form" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.reply_to.email).to eq("jane@example.com")
        expect(email.reply_to.name).to eq("Jane Doe")
      end
    end

    it "sets a subject naming the sender" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.subject).to eq("New contact message from Jane Doe")
      end
    end

    it "renders the message body into html_content" do
      run_mailer
      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.html_content).to include("Jane Doe")
        expect(email.html_content).to include("jane@example.com")
        expect(email.html_content).to include("Hi, when will my order ship?")
      end
    end

    it "uses a configured recipient override when present" do
      allow(Rails.application.credentials).to receive(:dig)
        .with(:brevo, :contact_notification_recipient)
        .and_return("support@example.com")

      run_mailer

      expect(brevo_api).to have_received(:send_transac_email) do |email|
        expect(email.to.first.email).to eq("support@example.com")
      end
    end
  end
end
