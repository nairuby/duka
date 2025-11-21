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
    it "returns apparel category for t-shirt" do
      product = double("Product", name: "Premium T-Shirt")
      category = helper.product_category(product)

      expect(category[:name]).to eq("Apparel")
      expect(category[:icon]).to eq("fas fa-tshirt")
      expect(category[:color]).to eq("red")
    end

    it "returns drinkware category for mug" do
      product = double("Product", name: "Coffee Mug")
      category = helper.product_category(product)

      expect(category[:name]).to eq("Drinkware")
      expect(category[:icon]).to eq("fas fa-mug-hot")
      expect(category[:color]).to eq("orange")
    end

    it "returns accessories category for notebook" do
      product = double("Product", name: "Developer Notebook")
      category = helper.product_category(product)

      expect(category[:name]).to eq("Accessories")
      expect(category[:icon]).to eq("fas fa-bookmark")
      expect(category[:color]).to eq("purple")
    end

    it "returns default category for unknown product" do
      product = double("Product", name: "Unknown Item")
      category = helper.product_category(product)

      expect(category[:name]).to eq("Product")
      expect(category[:icon]).to eq("fas fa-tag")
      expect(category[:color]).to eq("blue")
    end
  end

  describe "#category_badge_classes" do
    it "returns red classes for red color" do
      classes = helper.category_badge_classes("red")
      expect(classes).to eq("bg-red-100 text-red-700 border-red-200")
    end

    it "returns orange classes for orange color" do
      classes = helper.category_badge_classes("orange")
      expect(classes).to eq("bg-orange-100 text-orange-700 border-orange-200")
    end

    it "returns purple classes for purple color" do
      classes = helper.category_badge_classes("purple")
      expect(classes).to eq("bg-purple-100 text-purple-700 border-purple-200")
    end

    it "returns blue classes for unknown color" do
      classes = helper.category_badge_classes("unknown")
      expect(classes).to eq("bg-blue-100 text-blue-700 border-blue-200")
    end
  end
end
