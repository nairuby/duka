class ContactMailer < ApplicationMailer
  # Unlike OrderMailer, this renders a local view and sends it as html_content
  # directly rather than using a Brevo-hosted template — no dashboard template
  # or extra credential needs to exist for this to work.
  def new_message(contact_message)
    @contact_message = contact_message
    send_via_brevo(contact_message)
  end

  private

  def send_via_brevo(contact_message)
    api = Brevo::TransactionalEmailsApi.new
    send_smtp_email = Brevo::SendSmtpEmail.new
    send_smtp_email.to = [ Brevo::SendSmtpEmailTo.new(email: recipient_email) ]
    send_smtp_email.sender = Brevo::SendSmtpEmailSender.new(
      name: "ARC Duka Contact Form",
      email: "orders@shop.rubycommunity.africa"
    )
    # So replying to the notification email goes straight to the person who
    # submitted the form, not back to our own orders@ address.
    send_smtp_email.reply_to = Brevo::SendSmtpEmailReplyTo.new(
      name: contact_message.name,
      email: contact_message.email
    )
    send_smtp_email.subject = "New contact message from #{contact_message.name}"
    send_smtp_email.html_content = render_to_string(
      template: "contact_mailer/new_message",
      layout: "mailer",
      formats: [ :html ]
    )
    api.send_transac_email(send_smtp_email)
  rescue Brevo::ApiError => e
    Rails.logger.error("Brevo API error sending contact message #{contact_message.id}: #{e.message}")
    raise
  end

  def recipient_email
    Rails.application.credentials.dig(:brevo, :contact_notification_recipient) || "info@rubycommunity.africa"
  end
end
