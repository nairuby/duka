class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    @order_items = order.order_items

    html_body = render_to_string(
      template: "order_mailer/confirmation",
      layout: "mailer",
      formats: [ :html ]
    )

    send_via_brevo(
      to: order.email,
      subject: "Order Confirmation - #{order.order_number}",
      html_content: html_body
    )
  end

  private

  def send_via_brevo(to:, subject:, html_content:)
    api = Brevo::TransactionalEmailsApi.new

    send_smtp_email = Brevo::SendSmtpEmail.new
    send_smtp_email.to = [ Brevo::SendSmtpEmailTo.new(email: to) ]
    send_smtp_email.sender = Brevo::SendSmtpEmailSender.new(name: "Ruby Community Shop", email: "orders@shop.rubycommunity.africa")
    send_smtp_email.subject = subject
    send_smtp_email.html_content = html_content

    api.send_transac_email(send_smtp_email)
  rescue Brevo::ApiError => e
    Rails.logger.error("Brevo API error for order #{@order&.order_number}: #{e.message}")
    raise
  end
end
