class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    @order_items = @order.order_items

    mail to: @order.email, subject: "Order Confirmation - #{@order.order_number}"
  end
end
