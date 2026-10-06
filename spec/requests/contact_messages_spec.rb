require 'rails_helper'

RSpec.describe "ContactMessages", type: :request do
  before { ActiveJob::Base.queue_adapter = :test }

  describe "GET /contact" do
    it "returns http success" do
      get "/contact"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /contact" do
    let(:valid_params) do
      {
        contact_message: {
          name: "Jane Doe",
          email: "jane@example.com",
          subject: "Question",
          message: "Hi, when will my order ship?"
        }
      }
    end

    it "creates a ContactMessage and enqueues the notification email" do
      expect {
        post "/contact", params: valid_params
      }.to change(ContactMessage, :count).by(1)
        .and have_enqueued_mail(ContactMailer, :new_message)

      expect(response).to redirect_to(new_contact_message_path)
    end

    it "does not create a record or enqueue mail when the honeypot field is filled" do
      spam_params = valid_params.deep_merge(contact_message: { nickname: "I am a bot" })

      expect {
        post "/contact", params: spam_params
      }.not_to have_enqueued_mail(ContactMailer, :new_message)

      expect(ContactMessage.count).to eq(0)

      # Still looks like success to whatever filled it in.
      expect(response).to redirect_to(new_contact_message_path)
    end

    it "re-renders with errors and does not create a record for invalid params" do
      invalid_params = { contact_message: { name: "", email: "not-an-email", message: "" } }

      expect {
        post "/contact", params: invalid_params
      }.not_to change(ContactMessage, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
