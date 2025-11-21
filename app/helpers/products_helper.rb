module ProductsHelper
  def product_category(product)
    name = product.name.downcase

    case name
    when /t-shirt|hoodie|jacket|polo/
      { name: "Apparel", icon: "fas fa-tshirt", color: "red" }
    when /mug|bottle|tumbler/
      { name: "Drinkware", icon: "fas fa-mug-hot", color: "orange" }
    when /notebook|sticker|mouse pad|sleeve|pin/
      { name: "Accessories", icon: "fas fa-bookmark", color: "purple" }
    else
      { name: "Product", icon: "fas fa-tag", color: "blue" }
    end
  end

  def category_badge_classes(color)
    case color
    when "red"
      "bg-red-100 text-red-700 border-red-200"
    when "orange"
      "bg-orange-100 text-orange-700 border-orange-200"
    when "purple"
      "bg-purple-100 text-purple-700 border-purple-200"
    else
      "bg-blue-100 text-blue-700 border-blue-200"
    end
  end
end
