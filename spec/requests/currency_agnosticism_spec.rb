require 'rails_helper'

RSpec.describe "Currency Agnosticism", type: :request do
  describe "ApplicationController currency setup" do
    it "defaults to Kenya/KES when no location is found or default is used" do
      # Mock Geocoder to return nil/default behavior
      allow(Geocoder).to receive(:search).and_return([])

      # Spy on the Current setters
      expect(Current).to receive(:country_code=).with("KE")
      expect(Current).to receive(:currency=).with("KES")

      get root_path
    end
  end

  describe "Order creation defaults" do
    let(:user) { User.create!(email: "test@example.com", password: "password") }
    let(:product) { Product.create!(name: "Test Shirt", price: 1000, currency: "KES", category: "Shirts") }
    let(:cart_service) { CartService.new("session-123") }

    before do
      Current.currency = "KES"
      Current.country_code = "KE"
      cart_service.add_item(product.id)
    end

    it "uses Current attributes for order defaults" do
      checkout_params = {
        email: "buyer@example.com",
        phone: "0712345678",
        shipping_name: "Buyer",
        shipping_address: "123 Street",
        shipping_city: "Nairobi",
        shipping_postal_code: "00100"
        # shipping_country omitted to test default
      }

      order = Order.create_from_cart(cart_service, nil, checkout_params)

      expect(order.shipping_country).to eq("Kenya")
      expect(order.currency).to eq("KES")
    end
  end
end
