class CurrencyConverter
  EXCHANGE_RATES = {
    "USD" => 1.0,
    "KES" => 129.0
  }.freeze

  def self.convert(amount, from_currency, to_currency)
    return amount if from_currency == to_currency
    
    # Convert to base currency (USD) first, then to target currency
    amount_in_usd = amount / EXCHANGE_RATES[from_currency]
    
    (amount_in_usd * EXCHANGE_RATES[to_currency]).round(2)
  end
end
