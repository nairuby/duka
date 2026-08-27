class Avo::Filters::LowStockFilter < Avo::Filters::BooleanFilter
  self.name = "Stock Status"

  def apply(request, query, values)
    if values["low_stock"]
      query = query.where("stock_quantity < ?", 10)
    end

    if values["out_of_stock"]
      query = query.where(stock_quantity: 0)
    end

    if values["in_stock"]
      query = query.where("stock_quantity > ?", 0)
    end

    query
  end

  def options
    {
      low_stock: "Low Stock (< 10)",
      out_of_stock: "Out of Stock",
      in_stock: "In Stock"
    }
  end
end
