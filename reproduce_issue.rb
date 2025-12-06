user = User.first || User.create!(email: "test@example.com", password: "password", password_confirmation: "password")
product = Product.first
variant = product.variants.first

# Create a cart and add item
session_id = SecureRandom.uuid
cart_service = CartService.new(session_id)
cart_service.add_item(product.id, variant_id: variant.id, quantity: 1)

checkout_params = {
  email: "test@example.com",
  phone: "1234567890",
  shipping_name: "Test User",
  shipping_address: "123 Test St",
  shipping_city: "Nairobi",
  shipping_postal_code: "00100",
  shipping_country: "Kenya",
  notes: "Test order"
}

puts "Attempting to create order..."
begin
  order = Order.create_from_cart(cart_service, user, checkout_params)
  puts "Order created successfully: #{order.id}"
rescue => e
  puts "Error: #{e.class} - #{e.message}"
  puts e.backtrace
end
