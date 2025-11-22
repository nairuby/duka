class Avo::Cards::LowStockMetric < Avo::Cards::MetricCard
  self.id = "low_stock_metric"
  self.label = "Low Stock"
  self.description = "Variants with less than 10 items"
  self.cols = 1

  def query
    result Variant.where("stock_quantity < ? AND stock_quantity > 0", 10).count
  end
end
