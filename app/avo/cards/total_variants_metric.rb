class Avo::Cards::TotalVariantsMetric < Avo::Cards::MetricCard
  self.id = "total_variants_metric"
  self.label = "Total Variants"
  self.description = "All product variants"
  self.cols = 1

  def query
    result Variant.count
  end
end
