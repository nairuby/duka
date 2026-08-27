# Product Variants Guide

## Overview

Products in ARC Duka can be sold with or without variants. Variants are optional and should only be used when a product has multiple options like size, color, or style.

## When to Use Variants

### Use Variants When:
- Product has multiple sizes (S, M, L, XL)
- Product has multiple colors (Red, Blue, Black)
- Product has different styles or configurations
- You need to track separate stock levels for each option

**Examples:**
- T-Shirts (sizes: S, M, L, XL; colors: Red, Blue, Black)
- Hoodies (sizes: S, M, L, XL; colors: Navy, Gray)
- Hats (sizes: One Size; colors: Red, Blue, Green)

### Don't Use Variants When:
- Product is sold as-is with no options
- Product is a single item (mugs, stickers, accessories)
- All items are identical

**Examples:**
- Coffee Mugs (standard size)
- Sticker Packs (one design)
- Laptop Sleeves (universal fit)
- Notebooks (standard size)

## How It Works

### Products WITHOUT Variants
1. Create product in admin panel
2. Set price, description, category
3. **Don't create any variants**
4. Product is immediately available for purchase
5. Customers can add directly to cart

### Products WITH Variants
1. Create product in admin panel
2. Set base price, description, category
3. **Create variants** for each combination:
   - Size + Color combinations
   - Each variant has its own SKU and stock quantity
4. Customers must select size/color before adding to cart

## Adding Products in Admin Panel

### Simple Product (No Variants)

1. Go to `/avo/resources/products`
2. Click "Create new product"
3. Fill in:
   - Name: "Ruby Coffee Mug"
   - Description: "Premium ceramic mug with Ruby logo"
   - Price: 15.00
   - Currency: KES
   - Category: Mugs
   - Image URL: (optional)
4. Click "Save"
5. **Done!** Product is ready to sell

### Product with Variants

1. Create the product first (as above)
2. Go to the product detail page
3. Click "Variants" tab
4. For each variant, click "Create new variant":
   - Product: (auto-selected)
   - SKU: "RUBY-MUG-S-RED"
   - Size: "S"
   - Color: "Red"
   - Stock Quantity: 50
5. Repeat for all combinations
6. **Done!** Product with variants is ready

## Stock Management

### Products Without Variants
- No stock tracking by default
- Always available for purchase
- Can be enhanced later to add simple stock field to Product model

### Products With Variants
- Each variant has its own stock quantity
- Stock is tracked per variant
- Low stock alerts in admin panel
- Out of stock variants are disabled on product page

## Customer Experience

### Viewing Products Without Variants
- Product page shows price and description
- Green "Ready to order" badge displayed
- "Add to Cart" button is immediately active
- No selection required

### Viewing Products With Variants
- Product page shows size and color options
- Customer must select both size and color
- Stock availability shown after selection
- "Add to Cart" button enabled after selection

## Admin Panel Features

### Product Management
- View all products
- Filter by category
- Search by name or description
- Edit product details
- View associated variants

### Variant Management
- View all variants
- Filter by stock status (low stock, out of stock, in stock)
- Search by SKU, size, or color
- Update stock quantities
- Edit variant details

### Stock Dashboard
- Total products count
- Total variants count
- Low stock alerts (< 10 items)
- Out of stock count

## Best Practices

### Naming Conventions

**SKUs for Variants:**
```
Format: PRODUCT-SIZE-COLOR-RANDOM
Example: RUBY-TEE-M-BLK-A1B2
```

**Product Names:**
- Keep concise and descriptive
- Include key features
- Examples:
  - "Premium Cotton T-Shirt"
  - "Developer Hoodie"
  - "Ruby Coffee Mug"

### Pricing Strategy

**Products Without Variants:**
- Set one price for the product
- Simple and straightforward

**Products With Variants:**
- All variants share the same price (current implementation)
- Future: Can add variant-specific pricing if needed

### Inventory Management

**Starting Out:**
1. Add simple products first (no variants)
2. Test the checkout flow
3. Add variant products as needed
4. Monitor stock levels in admin panel

**Ongoing:**
1. Check low stock alerts weekly
2. Update stock quantities as inventory arrives
3. Mark out-of-stock items
4. Consider removing variants with consistently zero stock

## Migration Path

### Converting Simple Product to Variant Product

If you start with a simple product and later want to add variants:

1. Note the current product details
2. Create variants for all options
3. Customers will now need to select options
4. Existing cart items (without variants) will still work

### Converting Variant Product to Simple Product

If you want to simplify a variant product:

1. Delete all variants in admin panel
2. Product becomes simple product
3. Customers can add directly to cart

## Technical Details

### Database Schema

**Products Table:**
- No stock quantity field (variants handle stock)
- Price is base price
- Can be sold without variants

**Variants Table:**
- Optional (belongs_to :product)
- Has size, color, SKU
- Tracks stock_quantity
- Each variant is unique per product

### Cart Behavior

**Adding Without Variant:**
```ruby
cart.add_item(product_id: 123, variant_id: nil, quantity: 1)
```

**Adding With Variant:**
```ruby
cart.add_item(product_id: 123, variant_id: 456, quantity: 1)
```

### Order Processing

**Products Without Variants:**
- OrderItem stores product_id only
- variant_id is null
- Product name captured at order time

**Products With Variants:**
- OrderItem stores both product_id and variant_id
- Variant details (size/color) captured at order time
- Historical record preserved even if variant deleted

## FAQ

**Q: Do I need to create variants for every product?**
A: No! Only create variants if your product has multiple options. Simple products work great without variants.

**Q: Can I add variants later?**
A: Yes, you can add variants to any product at any time through the admin panel.

**Q: What happens to orders if I delete a variant?**
A: Past orders preserve the variant details (size/color) even if the variant is deleted. This ensures order history remains accurate.

**Q: Can I have different prices for different variants?**
A: Currently, all variants share the product's base price. This can be enhanced in the future if needed.

**Q: How do I track stock for simple products?**
A: Currently, simple products (without variants) don't track stock. They're always available. This can be enhanced by adding a stock field to the Product model.

**Q: Can a product have only size OR only color variants?**
A: Yes! You can create variants with just size (color can be empty) or just color (size can be empty). The system is flexible.

## Examples

### Example 1: Coffee Mug (No Variants)
```
Product:
- Name: "Ruby Coffee Mug"
- Price: KES 800
- Category: Mugs
- Variants: None

Result: Customers can immediately add to cart
```

### Example 2: T-Shirt (With Variants)
```
Product:
- Name: "Premium Cotton T-Shirt"
- Price: KES 1,500
- Category: Shirts

Variants:
1. Size: S, Color: Black, Stock: 20
2. Size: S, Color: White, Stock: 15
3. Size: M, Color: Black, Stock: 25
4. Size: M, Color: White, Stock: 20
5. Size: L, Color: Black, Stock: 18
6. Size: L, Color: White, Stock: 12

Result: Customers must select size and color before adding to cart
```

## Summary

**Simple Rule:** 
- No options needed? → Don't create variants
- Multiple options? → Create variants

This keeps your product management simple and your customers' experience smooth!
