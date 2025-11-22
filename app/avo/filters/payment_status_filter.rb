class Avo::Filters::PaymentStatusFilter < Avo::Filters::SelectFilter
  self.name = "Payment Status"

  def apply(request, query, value)
    query.where(payment_status: value)
  end

  def options
    Order::PAYMENT_STATUSES.map { |status| [status.titleize, status] }.to_h
  end
end
