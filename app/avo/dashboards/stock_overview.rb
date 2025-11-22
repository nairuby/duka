class Avo::Dashboards::StockOverview < Avo::Dashboards::BaseDashboard
  self.id = "stock_overview"
  self.name = "Stock Overview"
  self.description = "Monitor your inventory and stock levels"
  self.grid_cols = 4

  def cards
    card Avo::Cards::TotalProductsMetric
    card Avo::Cards::TotalVariantsMetric
    card Avo::Cards::LowStockMetric
    card Avo::Cards::OutOfStockMetric
  end
end
