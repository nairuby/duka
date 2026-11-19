# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Currencies", type: :request do
  describe "PATCH /currency" do
    it "updates session currency to USD" do
      patch currency_path, params: { currency: "USD" }
      expect(response).to redirect_to(root_path)
      expect(session[:currency]).to eq("USD")
    end

    it "updates session currency to KES" do
      patch currency_path, params: { currency: "KES" }
      expect(response).to redirect_to(root_path)
      expect(session[:currency]).to eq("KES")
    end

    it "ignores unsupported currencies" do
      patch currency_path, params: { currency: "XYZ" }
      expect(response).to redirect_to(root_path)
      expect(session[:currency]).not_to eq("XYZ")
    end
  end
end
