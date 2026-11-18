# frozen_string_literal: true

require "rails_helper"

RSpec.describe CurrencyConverter do
  describe ".convert" do
    it "returns the same amount when from and to currencies match" do
      expect(CurrencyConverter.convert(100.0, "KES", "KES")).to eq(100.0)
      expect(CurrencyConverter.convert(50.0, "USD", "USD")).to eq(50.0)
    end

    it "converts USD to KES at current exchange rate" do
      # 10 USD * 129.0 = 1290 KES
      expect(CurrencyConverter.convert(10.0, "USD", "KES")).to eq(1290.0)
    end

    it "converts KES to USD at current exchange rate and rounds to 2 decimals" do
      # 129 KES / 129.0 = 1.0 USD
      expect(CurrencyConverter.convert(129.0, "KES", "USD")).to eq(1.0)
      # 258 KES / 129.0 = 2.0 USD
      expect(CurrencyConverter.convert(258.0, "KES", "USD")).to eq(2.0)
    end
  end
end
