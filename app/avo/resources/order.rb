class Avo::Resources::Order < Avo::BaseResource
  self.title = :order_number
  self.includes = [ :user, :order_items ]

  self.search = {
    query: -> { query.where("order_number ILIKE ? OR email ILIKE ? OR phone ILIKE ?", "%#{q}%", "%#{q}%", "%#{q}%") }
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :order_number, as: :text, sortable: true, link_to_record: true
    field :user, as: :belongs_to, searchable: true
    field :email, as: :text, sortable: true
    field :phone, as: :text

    field :status, as: :select,
      options: Order::STATUSES.map { |s| [ s.titleize, s ] }.to_h,
      filterable: true,
      sortable: true

    field :payment_status, as: :select,
      options: Order::PAYMENT_STATUSES.map { |s| [ s.titleize, s ] }.to_h,
      filterable: true,
      sortable: true

    field :payment_method, as: :select,
      options: Order::PAYMENT_METHODS.map { |m| [ m.titleize, m ] }.to_h,
      filterable: true

    field :payment_reference, as: :text

    field :subtotal, as: :number, sortable: true, format_using: -> { number_to_currency(value, unit: record.currency + " ") }
    field :shipping_cost, as: :number, format_using: -> { number_to_currency(value, unit: record.currency + " ") }
    field :total, as: :number, sortable: true, format_using: -> { number_to_currency(value, unit: record.currency + " ") }
    field :currency, as: :text

    field :shipping_name, as: :text
    field :shipping_address, as: :textarea, hide_on: [ :index ]
    field :shipping_city, as: :text
    field :shipping_postal_code, as: :text, hide_on: [ :index ]
    field :shipping_country, as: :text

    field :notes, as: :textarea, hide_on: [ :index ]

    field :order_items, as: :has_many, show_on: :show

    field :created_at, as: :date_time, sortable: true, hide_on: [ :new, :edit ]
    field :updated_at, as: :date_time, sortable: true, hide_on: [ :new, :edit ]
  end

  def filters
    filter Avo::Filters::OrderStatusFilter
    filter Avo::Filters::PaymentStatusFilter
  end
end
