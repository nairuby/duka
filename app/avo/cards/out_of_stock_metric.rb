class Avo::Cards::OutOfStockMetric < Avo::Cards::MetricCard
  self.id = "out_of_stock_metric"
  self.label = "Out of Stock"
  self.description = "Variants with 0 items"
  self.cols = 1

  def query
    result Variant.where(stock_quantity: 0).count
  end
end
