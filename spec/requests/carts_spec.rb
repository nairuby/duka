# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Carts", type: :request do
  let(:product) { Product.create!(name: "Dev Sticker Pack", price: 500.0, currency: "KES", category: "Stickers") }
  let(:variant) { Variant.create!(product: product, size: "Pack of 5", color: "Multi", stock_quantity: 8, sku: "STK-PK5") }

  describe "GET /cart" do
    it "renders the cart show page successfully" do
      get cart_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Shopping Cart")
    end
  end

  describe "POST /cart/add_item" do
    it "adds an item to cart and redirects back (HTML format)" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 2 }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:notice]).to include("#{product.name} added to cart")
    end

    it "adds an item with variant and responds to JSON" do
      post add_item_cart_path, params: { product_id: product.id, variant_id: variant.id, quantity: 3 }, as: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["success"]).to be(true)
      expect(json["cart_count"]).to eq(3)
    end

    it "adds an item and responds to turbo_stream" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 1 }, as: :turbo_stream
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "handles stock limit errors gracefully" do
      post add_item_cart_path, params: { product_id: product.id, variant_id: variant.id, quantity: 20 }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)
      expect(json["success"]).to be(false)
      expect(json["message"]).to include("available in stock")
    end

    it "handles stock limit errors via HTML format" do
      post add_item_cart_path, params: { product_id: product.id, variant_id: variant.id, quantity: 20 }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:alert]).to include("available in stock")
    end
  end

  describe "PATCH /cart/update_quantity/:id" do
    it "updates item quantity via HTML" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 1 }
      item = CartItem.last

      patch update_quantity_cart_path(item.id), params: { quantity: 3 }
      expect(response).to redirect_to(cart_path)
      expect(item.reload.quantity).to eq(3)
    end

    it "handles quantity update exceeding stock via HTML" do
      post add_item_cart_path, params: { product_id: product.id, variant_id: variant.id, quantity: 1 }
      item = CartItem.last

      patch update_quantity_cart_path(item.id), params: { quantity: 50 }
      expect(response).to redirect_to(cart_path)
      follow_redirect!
      expect(flash[:alert]).to include("available in stock")
    end

    it "updates item quantity via turbo_stream" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 1 }
      item = CartItem.last

      patch update_quantity_cart_path(item.id), params: { quantity: 2 }, as: :turbo_stream
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "removes item when quantity is reduced to 0" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 1 }, as: :json
      item = CartItem.last

      patch update_quantity_cart_path(item.id), params: { quantity: 0 }, as: :json
      expect(response).to have_http_status(:success)
      expect(CartItem.find_by(id: item.id)).to be_nil
    end
  end

  describe "DELETE /cart/remove_item/:id" do
    it "removes item via HTML" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 2 }
      item = CartItem.last

      delete remove_item_cart_path(item.id)
      expect(response).to redirect_to(cart_path)
      follow_redirect!
      expect(flash[:notice]).to eq("Item removed from cart")
      expect(CartItem.find_by(id: item.id)).to be_nil
    end

    it "removes item via turbo_stream" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 2 }
      item = CartItem.last

      delete remove_item_cart_path(item.id), as: :turbo_stream
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end
  end

  describe "DELETE /cart/clear" do
    it "clears all items and redirects to root" do
      post add_item_cart_path, params: { product_id: product.id, quantity: 2 }

      delete clear_cart_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(flash[:notice]).to eq("Cart cleared")
    end
  end
end
