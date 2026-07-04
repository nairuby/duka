# Preview all emails at http://localhost:3000/rails/mailers/order_mailer_mailer
class OrderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/order_mailer_mailer/confirmation
  def confirmation
    OrderMailer.confirmation
  end
end
