# Development Guide

Welcome to the ARC Duka development guide! This document will help you get started with contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Organization](#code-organization)
- [Common Tasks](#common-tasks)
- [Testing](#testing)
- [Debugging](#debugging)
- [Best Practices](#best-practices)

## Getting Started

### First Time Setup

1. **Clone and setup**
   ```bash
   git clone https://github.com/nairuby/duka.git
   cd duka
   bundle install
   rails db:setup
   ```

2. **Create admin user**
   ```bash
   rails runner "User.create!(email: 'admin@test.com', password: 'password', admin: true)"
   ```

3. **Seed sample data**
   ```bash
   rails db:seed
   ```

4. **Start development server**
   ```bash
   bin/dev
   ```

### Development Tools

- **Rails Console:** `rails console` or `rails c`
- **Database Console:** `rails dbconsole` or `rails db`
- **Routes:** `rails routes | grep product`
- **Annotate Models:** `annotaterb models`

## Development Workflow

### Creating a New Feature

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Write tests first** (TDD approach)
   ```bash
   # Create spec file
   touch spec/models/your_model_spec.rb
   
   # Run tests
   bundle exec rspec spec/models/your_model_spec.rb
   ```

3. **Implement the feature**
   - Write minimal code to pass tests
   - Follow Rails conventions
   - Keep methods small and focused

4. **Test manually**
   - Test in browser
   - Check mobile responsiveness
   - Verify edge cases

5. **Commit and push**
   ```bash
   git add .
   git commit -m "Add feature: description"
   git push origin feature/your-feature-name
   ```

### Code Review Checklist

Before submitting a PR, ensure:
- [ ] All tests pass
- [ ] No RuboCop violations
- [ ] Documentation updated
- [ ] Mobile responsive
- [ ] Accessible (keyboard navigation, screen readers)
- [ ] No console errors
- [ ] Database migrations are reversible

## Code Organization

### Models (`app/models/`)

Business logic and data validation.

```ruby
class Product < ApplicationRecord
  # Associations first
  has_many :variants
  
  # Constants
  CATEGORIES = %w[Shirts Hoodies Mugs].freeze
  
  # Validations
  validates :name, presence: true
  
  # Scopes
  scope :by_category, ->(cat) { where(category: cat) }
  
  # Instance methods
  def display_name
    "#{name} (#{category})"
  end
  
  # Class methods
  def self.featured
    where(featured: true)
  end
end
```

### Controllers (`app/controllers/`)

Handle HTTP requests and responses.

```ruby
class ProductsController < ApplicationController
  before_action :set_product, only: [:show]
  
  def index
    @products = Product.all
  end
  
  def show
    @variants = @product.variants
  end
  
  private
  
  def set_product
    @product = Product.find(params[:id])
  end
end
```

### Services (`app/services/`)

Complex business logic extracted from models/controllers.

```ruby
class CartService
  def initialize(session_id)
    @session_id = session_id
  end
  
  def add_item(product_id, quantity: 1)
    # Implementation
  end
end
```

### Views (`app/views/`)

Templates using ERB and Tailwind CSS.

```erb
<div class="container mx-auto px-4">
  <h1 class="text-2xl font-bold"><%= @product.name %></h1>
  <p class="text-gray-600"><%= @product.description %></p>
</div>
```

### JavaScript (`app/javascript/controllers/`)

Stimulus controllers for interactivity.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  
  connect() {
    console.log("Controller connected")
  }
  
  greet() {
    this.outputTarget.textContent = "Hello!"
  }
}
```

## Common Tasks

### Adding a New Product

```ruby
# Via Rails console
Product.create!(
  name: "Ruby T-Shirt",
  description: "Comfortable cotton tee",
  price: 25.00,
  currency: "USD",
  category: "Shirts"
)
```

### Creating Product Variants

```ruby
product = Product.find_by(name: "Ruby T-Shirt")

['S', 'M', 'L'].each do |size|
  ['Red', 'Blue'].each do |color|
    product.variants.create!(
      size: size,
      color: color,
      sku: "RUBY-TEE-#{size}-#{color[0..2].upcase}",
      stock_quantity: 50
    )
  end
end
```

### Testing Cart Functionality

```ruby
# In Rails console
cart = CartService.new('test-session-123')
cart.add_item(product_id: 1, quantity: 2)
cart.items
cart.total
```

### Checking Order Status

```ruby
order = Order.find_by(order_number: 'ORD-20231122-ABC123')
order.status
order.payment_status
order.order_items
```

## Testing

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/models/product_spec.rb

# Specific line
bundle exec rspec spec/models/product_spec.rb:10

# With coverage
COVERAGE=true bundle exec rspec
```

### Writing Tests

```ruby
# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'requires a name' do
      product = Product.new(name: nil)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end
  end
  
  describe '#display_name' do
    it 'returns name with category' do
      product = Product.new(name: 'Mug', category: 'Mugs')
      expect(product.display_name).to eq('Mug (Mugs)')
    end
  end
end
```

### Test Factories

```ruby
# spec/factories/products.rb
FactoryBot.define do
  factory :product do
    name { "Test Product" }
    price { 19.99 }
    currency { "USD" }
    category { "Shirts" }
  end
end

# Usage
product = create(:product)
product = build(:product, name: "Custom Name")
```

## Debugging

### Rails Console Debugging

```ruby
# Start console
rails console

# Reload code
reload!

# Check associations
product = Product.first
product.variants.count
product.variants.pluck(:sku)

# Test methods
cart = CartService.new('test')
cart.add_item(1, quantity: 2)
```

### Debugging Views

```erb
<!-- Add debug output -->
<%= debug @product %>

<!-- Check variable type -->
<p>Type: <%= @product.class %></p>

<!-- Inspect object -->
<pre><%= @product.inspect %></pre>
```

### Debugging JavaScript

```javascript
// In Stimulus controller
connect() {
  console.log("Connected", this.element)
  console.log("Targets:", this.targets)
}

// Debug events
handleClick(event) {
  console.log("Event:", event)
  console.log("Target:", event.target)
  debugger // Pauses execution in browser
}
```

### Using Byebug

```ruby
# Add to code
def some_method
  byebug # Execution pauses here
  # ... rest of code
end

# In byebug console
n  # next line
s  # step into
c  # continue
l  # list code
var local  # show local variables
```

## Best Practices

### Ruby/Rails

1. **Follow Rails conventions**
   - Use RESTful routes
   - Keep controllers thin
   - Fat models, skinny controllers (or use services)

2. **Write readable code**
   ```ruby
   # Good
   def active_products
     Product.where(active: true).order(created_at: :desc)
   end
   
   # Avoid
   def ap
     Product.where(a: true).order(c: :desc)
   end
   ```

3. **Use meaningful names**
   ```ruby
   # Good
   user_count = User.count
   
   # Avoid
   uc = User.count
   ```

4. **Keep methods small**
   - Max 10 lines per method
   - Single responsibility
   - Extract complex logic to private methods

### Frontend

1. **Mobile-first design**
   ```html
   <!-- Start with mobile, add larger breakpoints -->
   <div class="text-sm sm:text-base lg:text-lg">
   ```

2. **Accessible HTML**
   ```html
   <!-- Use semantic HTML -->
   <button type="button" aria-label="Close cart">
     <i class="fas fa-times"></i>
   </button>
   ```

3. **Stimulus best practices**
   ```javascript
   // Use targets, not querySelector
   this.outputTarget.textContent = "Hello"
   
   // Clean up in disconnect
   disconnect() {
     clearInterval(this.interval)
   }
   ```

### Database

1. **Always add indexes**
   ```ruby
   add_index :products, :category
   add_index :orders, :status
   ```

2. **Make migrations reversible**
   ```ruby
   def change
     add_column :products, :featured, :boolean, default: false
   end
   ```

3. **Use database constraints**
   ```ruby
   add_column :products, :price, :decimal, null: false
   ```

### Git

1. **Write clear commit messages**
   ```
   Add product variant stock validation
   
   - Prevent adding more items than available stock
   - Show error message when stock limit reached
   - Update cart UI to show available stock
   ```

2. **Keep commits focused**
   - One feature/fix per commit
   - Don't mix refactoring with features

3. **Update branch before PR**
   ```bash
   git checkout main
   git pull
   git checkout feature/your-branch
   git rebase main
   ```

## Performance Tips

### Database Queries

```ruby
# Bad - N+1 query
products = Product.all
products.each { |p| puts p.variants.count }

# Good - Eager loading
products = Product.includes(:variants)
products.each { |p| puts p.variants.count }
```

### Caching

```ruby
# Fragment caching
<% cache @product do %>
  <%= render @product %>
<% end %>

# Russian doll caching
<% cache ['products', @products.maximum(:updated_at)] do %>
  <% @products.each do |product| %>
    <% cache product do %>
      <%= render product %>
    <% end %>
  <% end %>
<% end %>
```

### Background Jobs

```ruby
# For slow operations
class OrderConfirmationJob < ApplicationJob
  def perform(order_id)
    order = Order.find(order_id)
    OrderMailer.confirmation(order).deliver_now
  end
end

# Usage
OrderConfirmationJob.perform_later(order.id)
```

## Getting Help

- **Documentation:** Check `/docs` directory
- **Rails Guides:** https://guides.rubyonrails.org
- **Community:** Nairuby Slack/Discord
- **Issues:** GitHub Issues for bugs
- **Discussions:** GitHub Discussions for questions

## Next Steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for system overview
- Check [CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines
- Review [CHECKOUT_SYSTEM.md](CHECKOUT_SYSTEM.md) for checkout flow
- Explore [ADMIN_PANEL.md](ADMIN_PANEL.md) for admin features

Happy coding! 🚀
