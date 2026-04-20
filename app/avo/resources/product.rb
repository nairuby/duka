class Avo::Resources::Product < Avo::BaseResource
  self.title = :name
  self.includes = [ :variants ]

  self.search = {
    query: -> { query.where("name ILIKE ? OR description ILIKE ?", "%#{q}%", "%#{q}%") }
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :name, as: :text, required: true, sortable: true
    field :description, as: :textarea, rows: 4
    field :price, as: :number, required: true, min: 0, step: 0.01, sortable: true
    field :currency, as: :select,
      options: { "KES" => "KES", "USD" => "USD", "EUR" => "EUR", "GBP" => "GBP" },
      default: "KES",
      required: true
    field :category, as: :select,
      options: Product::CATEGORIES.map { |c| [ c, c ] }.to_h,
      include_blank: "Select Category",
      filterable: true,
      sortable: true
    field :image_url, as: :text, help: "Enter the URL of the product image"
    field :variants, as: :has_many, show_on: :show
    field :created_at, as: :date_time, sortable: true, hide_on: [ :new, :edit ]
    field :updated_at, as: :date_time, sortable: true, hide_on: [ :new, :edit ]
  end

  def filters
    filter Avo::Filters::CategoryFilter
  end
end
