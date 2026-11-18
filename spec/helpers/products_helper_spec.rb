require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ProductsHelper. For example:
#
# describe ProductsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ProductsHelper, type: :helper do
  describe "#product_category" do
    it "returns shirts category for t-shirt" do
      product = double("Product", name: "Premium T-Shirt", category: "Shirts")
      category = helper.product_category(product)

      expect(category[:name]).to eq("Shirts")
      expect(category[:icon]).to eq("fas fa-tshirt")
      expect(category[:color]).to eq("red")
    end

    it "returns mugs category for mug" do
      product = double("Product", name: "Coffee Mug", category: "Mugs")
      category = helper.product_category(product)

      expect(category[:name]).to eq("Mugs")
      expect(category[:icon]).to eq("fas fa-mug-hot")
      expect(category[:color]).to eq("orange")
    end

    it "returns accessories category for notebook" do
      product = double("Product", name: "Developer Notebook", category: "Accessories")
      category = helper.product_category(product)

      expect(category[:name]).to eq("Accessories")
      expect(category[:icon]).to eq("fas fa-gift")
      expect(category[:color]).to eq("purple")
    end

    it "returns default category for unknown product" do
      product = double("Product", name: "Unknown Item", category: nil)
      category = helper.product_category(product)

      expect(category[:name]).to eq("Accessories")
      expect(category[:icon]).to eq("fas fa-gift")
      expect(category[:color]).to eq("purple")
    end

    it "handles all supported category types" do
      expect(helper.category_info("Hoodies")[:color]).to eq("blue")
      expect(helper.category_info("Hats")[:color]).to eq("green")
      expect(helper.category_info("Bags")[:color]).to eq("yellow")
      expect(helper.category_info("Stickers")[:color]).to eq("pink")
      expect(helper.category_info("Custom")[:color]).to eq("gray")
    end
  end

  describe "#category_badge_classes" do
    it "returns red classes for red color" do
      classes = helper.category_badge_classes("red")
      expect(classes).to eq("bg-red-100 text-red-700 border-red-200")
    end

    it "returns expected badge classes for all theme colors" do
      expect(helper.category_badge_classes("blue")).to include("bg-blue-100")
      expect(helper.category_badge_classes("green")).to include("bg-green-100")
      expect(helper.category_badge_classes("yellow")).to include("bg-yellow-100")
      expect(helper.category_badge_classes("pink")).to include("bg-pink-100")
    end

    it "returns orange classes for orange color" do
      classes = helper.category_badge_classes("orange")
      expect(classes).to eq("bg-orange-100 text-orange-700 border-orange-200")
    end

    it "returns purple classes for purple color" do
      classes = helper.category_badge_classes("purple")
      expect(classes).to eq("bg-purple-100 text-purple-700 border-purple-200")
    end

    it "returns gray classes for unknown color" do
      classes = helper.category_badge_classes("unknown")
      expect(classes).to eq("bg-gray-100 text-gray-700 border-gray-200")
    end
  end
end
