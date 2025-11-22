class Avo::Resources::Variant < Avo::BaseResource
  self.title = :sku
  self.includes = [:product]
  
  self.search = {
    query: -> { query.where("sku ILIKE ? OR color ILIKE ? OR size ILIKE ?", "%#{q}%", "%#{q}%", "%#{q}%") }
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :product, as: :belongs_to, required: true, searchable: true
    field :sku, as: :text, required: true, help: "Unique stock keeping unit", sortable: true
    field :size, as: :text, required: true, sortable: true
    field :color, as: :text, required: true, sortable: true
    field :stock_quantity, as: :number, 
      required: true, 
      min: 0, 
      sortable: true,
      help: "Current stock quantity"
    field :created_at, as: :date_time, sortable: true, hide_on: [:new, :edit]
    field :updated_at, as: :date_time, sortable: true, hide_on: [:new, :edit]
  end

  def filters
    filter Avo::Filters::LowStockFilter
  end
end
