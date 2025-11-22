class CartService
  attr_reader :session_id

  def initialize(session_id)
    @session_id = session_id
  end

  def items
    @items ||= CartItem.where(session_id: session_id).includes(:product, :variant).order(created_at: :desc)
  end

  def add_item(product_id, variant_id: nil, quantity: 1)
    item = CartItem.find_or_initialize_by(
      session_id: session_id,
      product_id: product_id,
      variant_id: variant_id
    )

    item.quantity = item.persisted? ? item.quantity + quantity : quantity
    item.save!
    item
  end

  def update_quantity(cart_item_id, quantity)
    item = items.find(cart_item_id)
    if quantity > 0
      item.update!(quantity: quantity)
    else
      item.destroy!
    end
    item
  end

  def remove_item(cart_item_id)
    item = items.find(cart_item_id)
    item.destroy!
  end

  def clear
    items.destroy_all
  end

  def total_items
    items.sum(:quantity)
  end

  def subtotal
    items.sum(&:subtotal)
  end

  def total
    subtotal # Can add tax, shipping, etc. later
  end

  def empty?
    items.empty?
  end

  def suggested_products(limit: 4)
    return Product.order("RANDOM()").limit(limit) if empty?

    # Get products from same categories as cart items
    categories = items.map { |item| item.product.category }.compact.uniq
    product_ids = items.pluck(:product_id)

    Product.where(category: categories)
           .where.not(id: product_ids)
           .order("RANDOM()")
           .limit(limit)
  end
end
