# System Architecture

This document provides an overview of the ARC Duka system architecture, design decisions, and technical implementation.

## Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [System Components](#system-components)
- [Data Models](#data-models)
- [Request Flow](#request-flow)
- [Frontend Architecture](#frontend-architecture)
- [Backend Architecture](#backend-architecture)
- [Security](#security)
- [Performance](#performance)

## Overview

ARC Duka is a modern e-commerce platform built with Ruby on Rails 8, following a monolithic architecture with modern frontend patterns using Hotwire (Turbo + Stimulus).

### Design Principles

1. **Convention over Configuration** - Follow Rails conventions
2. **Progressive Enhancement** - Works without JavaScript, enhanced with it
3. **Mobile-First** - Responsive design starting from mobile
4. **Accessibility** - WCAG 2.1 AA compliant
5. **Performance** - Fast page loads and instant interactions

## Technology Stack

### Backend
- **Ruby 3.4.7** - Programming language
- **Rails 8.1** - Web framework
- **PostgreSQL 14+** - Primary database
- **Solid Queue** - Background jobs
- **Solid Cache** - Caching layer
- **Solid Cable** - WebSocket connections

### Frontend
- **Hotwire Turbo** - SPA-like navigation without JavaScript frameworks
- **Stimulus** - Modest JavaScript framework
- **Tailwind CSS 4.0** - Utility-first CSS
- **Font Awesome** - Icons

### Admin
- **Avo 3.0** - Admin panel framework
- **Devise** - Authentication

### Development
- **RSpec** - Testing framework
- **RuboCop** - Code linter
- **Annotaterb** - Model annotations
- **Bullet** - N+1 query detection

## System Components

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Customer   │  │    Admin     │  │   Mobile     │     │
│  │     UI       │  │     Panel    │  │     App      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Rails Application                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    Controllers                        │  │
│  │  Products │ Cart │ Checkout │ Orders │ Admin        │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                     Services                          │  │
│  │  CartService │ OrderService │ PaymentService        │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                      Models                           │  │
│  │  Product │ Variant │ Order │ OrderItem │ User       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      PostgreSQL                              │
│  Products │ Variants │ Orders │ Users │ CartItems          │
└─────────────────────────────────────────────────────────────┘
```

## Data Models

### Core Models

#### Product
```ruby
Product
├── id (uuid)
├── name (string)
├── description (text)
├── price (decimal)
├── currency (string)
├── category (string)
├── image_url (string)
└── has_many :variants
```

#### Variant
```ruby
Variant
├── id (uuid)
├── product_id (uuid)
├── sku (string, unique)
├── size (string)
├── color (string)
├── stock_quantity (integer)
└── belongs_to :product
```

#### Order
```ruby
Order
├── id (uuid)
├── user_id (uuid, optional)
├── order_number (string, unique)
├── email (string)
├── phone (string)
├── status (enum: pending, confirmed, processing, shipped, delivered, cancelled)
├── payment_method (enum: card, bank_transfer, cash_on_delivery)
├── payment_status (enum: pending, paid, failed, refunded)
├── subtotal (decimal)
├── shipping_cost (decimal)
├── total (decimal)
├── shipping_address (text)
├── belongs_to :user (optional)
└── has_many :order_items
```

#### OrderItem
```ruby
OrderItem
├── id (uuid)
├── order_id (uuid)
├── product_id (uuid)
├── variant_id (uuid, optional)
├── quantity (integer)
├── price (decimal)
├── subtotal (decimal)
├── product_name (string) # Snapshot
├── variant_details (string) # Snapshot
├── belongs_to :order
├── belongs_to :product
└── belongs_to :variant (optional)
```

#### User
```ruby
User
├── id (uuid)
├── email (string, unique)
├── encrypted_password (string)
├── admin (boolean)
└── has_many :orders
```

#### CartItem
```ruby
CartItem
├── id (uuid)
├── session_id (string)
├── product_id (uuid)
├── variant_id (uuid, optional)
├── quantity (integer)
├── belongs_to :product
└── belongs_to :variant (optional)
```

### Relationships

```
User ──< Orders ──< OrderItems >── Products
                                    │
                                    └──< Variants

CartItems >── Products
    │          │
    │          └──< Variants
    └── Session (string)
```

## Request Flow

### Product Browsing

```
1. User visits homepage
   ↓
2. HomeController#index
   ↓
3. Load products grouped by category
   ↓
4. Render view with Turbo
   ↓
5. User clicks product
   ↓
6. Turbo navigates (no full page reload)
   ↓
7. ProductsController#show
   ↓
8. Load product with variants
   ↓
9. Render product detail page
```

### Adding to Cart

```
1. User clicks "Add to Cart"
   ↓
2. Stimulus controller captures event
   ↓
3. POST /cart/add_item (Turbo Stream)
   ↓
4. CartsController#add_item
   ↓
5. CartService.add_item
   ↓
6. Validate stock availability
   ↓
7. Create/update CartItem
   ↓
8. Return Turbo Stream response
   ↓
9. Update cart preview (no page reload)
   ↓
10. Update cart count badge
```

### Checkout Flow

```
1. User clicks "Checkout"
   ↓
2. CheckoutsController#new
   ↓
3. Display shipping form
   ↓
4. User submits form
   ↓
5. CheckoutsController#create
   ↓
6. Order.create_from_cart
   ↓
7. Calculate shipping cost
   ↓
8. Create Order and OrderItems
   ↓
9. Redirect to payment selection
   ↓
10. User selects payment method
   ↓
11. CheckoutsController#process_payment
   ↓
12. Redirect to payment gateway OR
    Mark as COD and confirm
   ↓
13. Payment callback (webhook)
   ↓
14. Order.mark_as_paid!
   ↓
15. Send confirmation email
   ↓
16. Display confirmation page
```

## Frontend Architecture

### Hotwire Turbo

Turbo provides SPA-like navigation without writing JavaScript:

```html
<!-- Turbo Frame for isolated updates -->
<turbo-frame id="cart_preview">
  <%= render 'carts/preview' %>
</turbo-frame>

<!-- Turbo Stream for multiple updates -->
<%= turbo_stream.replace "cart_preview", partial: "carts/preview" %>
<%= turbo_stream.update "cart_count", @cart.total_items %>
```

### Stimulus Controllers

Organized by feature:

```
app/javascript/controllers/
├── cart_item_controller.js      # Cart item interactions
├── cart_preview_controller.js   # Cart sidebar
├── product_detail_controller.js # Product page
└── flash_controller.js          # Flash messages
```

Example controller:

```javascript
// cart_item_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantityDisplay"]
  static values = { itemId: String, quantity: Number }
  
  increase() {
    // Optimistic UI update
    this.quantityValue++
    this.quantityDisplayTarget.textContent = this.quantityValue
    
    // Server update (debounced)
    this.updateServer()
  }
}
```

### Styling Strategy

**Tailwind CSS** for utility-first styling:

```html
<!-- Responsive, mobile-first -->
<div class="text-sm sm:text-base lg:text-lg">
  <h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold">
    Product Name
  </h1>
</div>
```

**Component patterns:**

```html
<!-- Button component -->
<button class="bg-red-600 text-white px-4 py-2 rounded-xl hover:bg-red-700 transition-all">
  Add to Cart
</button>

<!-- Card component -->
<div class="bg-white rounded-2xl shadow-lg p-6">
  <!-- Content -->
</div>
```

## Backend Architecture

### Service Objects

Extract complex business logic from controllers and models:

```ruby
# app/services/cart_service.rb
class CartService
  def initialize(session_id)
    @session_id = session_id
  end
  
  def add_item(product_id, variant_id: nil, quantity: 1)
    # Validate stock
    # Create/update cart item
    # Return result
  end
  
  def total
    items.sum(&:subtotal)
  end
end
```

### Controller Pattern

Keep controllers thin:

```ruby
class ProductsController < ApplicationController
  def index
    @products = Product.includes(:variants).by_category(params[:category])
  end
  
  def show
    @product = Product.find(params[:id])
    @variants = @product.variants
  end
end
```

### Model Responsibilities

- **Validations** - Data integrity
- **Associations** - Relationships
- **Scopes** - Query helpers
- **Business logic** - Domain-specific methods

```ruby
class Product < ApplicationRecord
  # Associations
  has_many :variants
  
  # Validations
  validates :name, :price, presence: true
  
  # Scopes
  scope :by_category, ->(cat) { where(category: cat) }
  
  # Business logic
  def in_stock?
    variants.any? { |v| v.stock_quantity > 0 }
  end
end
```

## Security

### Authentication
- **Devise** for user authentication
- **Bcrypt** for password hashing
- Session-based authentication

### Authorization
- Admin-only routes protected by `authenticate_user!` and `admin?` check
- Guest checkout supported (no login required)

### CSRF Protection
- Rails CSRF tokens on all forms
- Verified on POST/PATCH/DELETE requests

### SQL Injection Prevention
- ActiveRecord parameterized queries
- Never use string interpolation in queries

### XSS Prevention
- ERB auto-escapes output
- Use `sanitize` for user-generated HTML

### Best Practices
```ruby
# Good - Parameterized
Product.where("name LIKE ?", "%#{params[:q]}%")

# Bad - SQL injection risk
Product.where("name LIKE '%#{params[:q]}%'")

# Good - Escaped output
<%= @product.name %>

# Bad - XSS risk
<%== @product.name %>
```

## Performance

### Database Optimization

**Indexes:**
```ruby
add_index :products, :category
add_index :orders, [:status, :created_at]
add_index :cart_items, [:session_id, :product_id, :variant_id], unique: true
```

**Eager Loading:**
```ruby
# Avoid N+1 queries
@products = Product.includes(:variants)
@orders = Order.includes(:order_items, :user)
```

### Caching Strategy

**Fragment Caching:**
```erb
<% cache @product do %>
  <%= render @product %>
<% end %>
```

**Russian Doll Caching:**
```erb
<% cache ['products', Product.maximum(:updated_at)] do %>
  <% @products.each do |product| %>
    <% cache product do %>
      <%= render product %>
    <% end %>
  <% end %>
<% end %>
```

### Frontend Performance

**Optimistic UI:**
- Update UI immediately
- Send server request in background
- Revert on error

**Debouncing:**
- Batch rapid user actions
- Reduce server requests

**Lazy Loading:**
- Load images on scroll
- Defer non-critical JavaScript

## Deployment

### Infrastructure
- **Kamal 2.0** for deployment
- **Docker** containers
- **PostgreSQL** database
- **Redis** for caching (optional)

### Environment Variables
```env
DATABASE_URL
SECRET_KEY_BASE
RAILS_ENV
STRIPE_SECRET_KEY
```

### Monitoring
- Rails logs
- Database query logs
- Error tracking (Sentry/Rollbar)
- Performance monitoring (New Relic/Scout)

## Future Enhancements

### Planned Features
- [ ] Email notifications
- [ ] Order tracking
- [ ] Inventory management
- [ ] Customer reviews
- [ ] Wishlist
- [ ] Product recommendations
- [ ] Multi-language support

### Technical Improvements
- [ ] GraphQL API
- [ ] Mobile app (React Native)
- [ ] Real-time notifications
- [ ] Advanced analytics
- [ ] A/B testing framework

## References

- [Rails Guides](https://guides.rubyonrails.org)
- [Hotwire Documentation](https://hotwired.dev)
- [Tailwind CSS](https://tailwindcss.com)
- [Avo Documentation](https://docs.avohq.io)

---

**Last Updated:** November 2024
