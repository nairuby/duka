module ProductsHelper
  def product_category(product)
    category = product.category || "Accessories"
    category_info(category)
  end

  def category_info(category_name)
    case category_name
    when "Shirts"
      { name: "Shirts", icon: "fas fa-tshirt", color: "red" }
    when "Hoodies"
      { name: "Hoodies", icon: "fas fa-vest", color: "blue" }
    when "Hats"
      { name: "Hats", icon: "fas fa-hat-cowboy", color: "green" }
    when "Bags"
      { name: "Bags", icon: "fas fa-bag-shopping", color: "yellow" }
    when "Mugs"
      { name: "Mugs", icon: "fas fa-mug-hot", color: "orange" }
    when "Stickers"
      { name: "Stickers", icon: "fas fa-note-sticky", color: "pink" }
    when "Accessories"
      { name: "Accessories", icon: "fas fa-gift", color: "purple" }
    else
      { name: category_name, icon: "fas fa-tag", color: "gray" }
    end
  end

  def category_badge_classes(color)
    case color
    when "red"
      "bg-red-100 text-red-700 border-red-200"
    when "blue"
      "bg-blue-100 text-blue-700 border-blue-200"
    when "green"
      "bg-green-100 text-green-700 border-green-200"
    when "yellow"
      "bg-yellow-100 text-yellow-700 border-yellow-200"
    when "orange"
      "bg-orange-100 text-orange-700 border-orange-200"
    when "pink"
      "bg-pink-100 text-pink-700 border-pink-200"
    when "purple"
      "bg-purple-100 text-purple-700 border-purple-200"
    else
      "bg-gray-100 text-gray-700 border-gray-200"
    end
  end
end
