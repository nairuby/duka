class Avo::Cards::TotalProductsMetric < Avo::Cards::MetricCard
  self.id = "total_products_metric"
  self.label = "Total Products"
  self.description = "All products in catalog"
  self.cols = 1

  def query
    result Product.count
  end
end
