class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order

    send_via_brevo(order)
  end

  private

  def send_via_brevo(order)
    api = Brevo::TransactionalEmailsApi.new

    send_smtp_email = Brevo::SendSmtpEmail.new
    send_smtp_email.to = [ Brevo::SendSmtpEmailTo.new(email: order.email) ]
    send_smtp_email.sender = Brevo::SendSmtpEmailSender.new(
      name: "Ruby Community Shop",
      email: "orders@shop.rubycommunity.africa"
    )
    send_smtp_email.template_id = Rails.application.credentials.dig(:brevo, :order_confirmation_template_id)
    send_smtp_email.subject = "Your order ##{order.order_number} is confirmed ✓"
    send_smtp_email.params = template_params(order)

    api.send_transac_email(send_smtp_email)
  rescue Brevo::ApiError => e
    Rails.logger.error("Brevo API error for order #{order.order_number}: #{e.message}")
    raise
  end

  def template_params(order)
    {
      order_number: order.order_number,
      order_date: order.created_at.strftime("%B %d, %Y"),
      customer_name: order.shipping_name,
      currency: order.currency,
      items: order.order_items.map { |item|
        {
          product_name: item.product_name,
          variant: item.variant_details.presence || "",
          quantity: item.quantity,
          subtotal: item.subtotal.to_s
        }
      },
      subtotal: order.subtotal.to_s,
      shipping: order.shipping_cost.to_s,
      total: order.total.to_s,
      address_line_1: order.shipping_address,
      city: order.shipping_city,
      postal_code: order.shipping_postal_code,
      country: order.shipping_country
    }
  end
end
