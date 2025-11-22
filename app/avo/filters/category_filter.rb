class Avo::Filters::CategoryFilter < Avo::Filters::SelectFilter
  self.name = "Category"

  def apply(request, query, value)
    query.where(category: value)
  end

  def options
    Product::CATEGORIES.map { |category| [ category, category ] }.to_h
  end
end
