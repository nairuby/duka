# Clear existing data
Variant.destroy_all
Product.destroy_all

# Product data with placeholder images
products_data = [
  {
    name: "Premium Cotton T-Shirt",
    description: "A comfortable and stylish cotton t-shirt made from premium materials. Perfect for casual wear or layering. Features a classic fit with reinforced seams for durability.",
    price: 29.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/3B82F6/FFFFFF?text=Premium+T-Shirt",
    category: "Apparel",
    sizes: ["XS", "S", "M", "L", "XL"],
    colors: ["Black", "White", "Navy", "Gray"]
  },
  {
    name: "Denim Jacket",
    description: "Classic denim jacket with a modern twist. Made from high-quality denim with a comfortable fit. Features multiple pockets and adjustable cuffs.",
    price: 89.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/1F2937/FFFFFF?text=Denim+Jacket",
    category: "Apparel",
    sizes: ["S", "M", "L", "XL"],
    colors: ["Blue", "Black", "Light Blue"]
  },
  {
    name: "Ruby Coffee Mug",
    description: "Premium ceramic mug featuring the iconic Ruby logo. Perfect for your morning coffee or afternoon tea. Dishwasher and microwave safe.",
    price: 18.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/DC2626/FFFFFF?text=Ruby+Mug",
    category: "Drinkware",
    sizes: ["Standard"],
    colors: ["Red", "Black", "White"]
  },
  {
    name: "Developer Hoodie",
    description: "Cozy hoodie with African-inspired patterns and Ruby community branding. Made from premium fleece for ultimate comfort during long coding sessions.",
    price: 65.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/7C3AED/FFFFFF?text=Dev+Hoodie",
    category: "Apparel",
    sizes: ["S", "M", "L", "XL", "XXL"],
    colors: ["Black", "Gray", "Navy"]
  },
  {
    name: "Coding Notebook",
    description: "Professional notebook with grid pages perfect for sketching algorithms and taking notes. Features a durable cover with Ruby community branding.",
    price: 15.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/F59E0B/FFFFFF?text=Notebook",
    category: "Accessories",
    sizes: ["A5"],
    colors: ["Black", "Red", "Blue"]
  },
  {
    name: "Tech Sticker Pack",
    description: "Collection of 20 high-quality vinyl stickers featuring Ruby gems, African patterns, and programming humor. Perfect for laptops and water bottles.",
    price: 12.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/10B981/FFFFFF?text=Stickers",
    category: "Accessories",
    sizes: ["Pack"],
    colors: ["Mixed"]
  },
  {
    name: "Wireless Mouse Pad",
    description: "Large gaming mouse pad with wireless charging zone. Features Ruby community artwork and provides smooth tracking for any mouse type.",
    price: 34.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/6366F1/FFFFFF?text=Mouse+Pad",
    category: "Accessories",
    sizes: ["Large"],
    colors: ["Black", "Gray"]
  },
  {
    name: "Heritage Polo Shirt",
    description: "Elegant polo shirt combining modern style with traditional African patterns. Made from breathable cotton blend for comfort and durability.",
    price: 45.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/EC4899/FFFFFF?text=Polo+Shirt",
    category: "Apparel",
    sizes: ["S", "M", "L", "XL"],
    colors: ["White", "Navy", "Red"]
  },
  {
    name: "Insulated Water Bottle",
    description: "Double-wall insulated water bottle keeps drinks cold for 24 hours or hot for 12 hours. Features Ruby community logo and leak-proof design.",
    price: 28.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/059669/FFFFFF?text=Water+Bottle",
    category: "Drinkware",
    sizes: ["500ml"],
    colors: ["Silver", "Black", "Blue"]
  },
  {
    name: "Laptop Sleeve",
    description: "Protective laptop sleeve with padding and African-inspired design. Fits most 13-15 inch laptops with additional pocket for accessories.",
    price: 39.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/B45309/FFFFFF?text=Laptop+Sleeve",
    category: "Accessories",
    sizes: ["13 inch", "15 inch"],
    colors: ["Brown", "Black", "Gray"]
  },
  {
    name: "Ruby Gem Pin Set",
    description: "Collectible enamel pin set featuring different Ruby gems and African symbols. High-quality metal construction with secure backing.",
    price: 22.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/DC2626/FFFFFF?text=Pin+Set",
    category: "Accessories",
    sizes: ["Set of 5"],
    colors: ["Mixed"]
  },
  {
    name: "Code & Coffee Tumbler",
    description: "Travel tumbler perfect for developers on the go. Features double-wall insulation and a spill-proof lid. Decorated with coding quotes.",
    price: 24.99,
    currency: "USD",
    image_url: "https://via.placeholder.com/400x400/374151/FFFFFF?text=Tumbler",
    category: "Drinkware",
    sizes: ["16oz"],
    colors: ["Black", "Silver", "Red"]
  }
]

# Create products and variants
products_data.each_with_index do |product_data, index|
  puts "Creating product #{index + 1}: #{product_data[:name]}"
  
  product = Product.create!(
    name: product_data[:name],
    description: product_data[:description],
    price: product_data[:price],
    currency: product_data[:currency],
    image_url: product_data[:image_url]
  )
  
  # Create variants for each product
  product_data[:sizes].each do |size|
    product_data[:colors].each do |color|
      Variant.create!(
        product: product,
        size: size,
        color: color,
        stock_quantity: rand(0..25),
        sku: "#{product_data[:name].upcase.gsub(/[^A-Z]/, '')[0..3]}-#{size.gsub(' ', '')}-#{color.gsub(' ', '').upcase}-#{SecureRandom.hex(2)}"
      )
    end
  end
end

puts "\n✅ Successfully created #{Product.count} products with #{Variant.count} variants"
puts "\nProducts created:"
Product.all.each_with_index do |product, index|
  puts "#{index + 1}. #{product.name} - #{product.currency}#{product.price} (#{product.variants.count} variants)"
end