class Avo::Filters::OrderStatusFilter < Avo::Filters::SelectFilter
  self.name = "Order Status"

  def apply(request, query, value)
    query.where(status: value)
  end

  def options
    Order::STATUSES.map { |status| [status.titleize, status] }.to_h
  end
end
