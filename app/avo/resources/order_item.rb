class Avo::Resources::OrderItem < Avo::BaseResource
  self.title = :product_name
  self.includes = [ :order, :product, :variant ]

  def fields
    field :id, as: :id
    field :order, as: :belongs_to, link_to_record: true
    field :product, as: :belongs_to, link_to_record: true
    field :variant, as: :belongs_to
    field :product_name, as: :text
    field :variant_details, as: :text
    field :quantity, as: :number
    field :price, as: :number, format_using: -> { number_to_currency(value) }
    field :subtotal, as: :number, format_using: -> { number_to_currency(value) }
    field :created_at, as: :date_time, hide_on: [ :new, :edit ]
  end
end
