# Contributing to ARC Duka

Thank you for your interest in contributing to ARC Duka! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Community](#community)

---

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please:

- **Be respectful** - Treat everyone with respect and kindness
- **Be collaborative** - Work together and help each other
- **Be inclusive** - Welcome newcomers and diverse perspectives
- **Be professional** - Keep discussions focused and constructive

Unacceptable behavior includes harassment, discrimination, or any form of abuse. Violations may result in removal from the project.

## Getting Started

### Prerequisites

- Ruby 3.4.7+
- Rails 8.1+
- PostgreSQL 14+
- Node.js 18+
- Git

### Setup

1. **Fork the repository**
   - Click "Fork" on GitHub
   - Clone your fork locally

2. **Install dependencies**
   ```bash
   cd duka
   bundle install
   yarn install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Run the application**
   ```bash
   bin/dev
   ```

5. **Verify setup**
   - Visit http://localhost:3000
   - Run tests: `bundle exec rspec`
   - Check linting: `bundle exec rubocop`

### Documentation

Read these docs before contributing:
- [DEVELOPMENT.md](docs/DEVELOPMENT.md) - Development guide
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture
- [README.md](README.md) - Project overview

## Development Process

### 1. Choose an Issue

- Browse [open issues](https://github.com/nairuby/duka/issues)
- Look for `good first issue` or `help wanted` labels
- Comment on the issue to claim it
- Ask questions if anything is unclear

### 2. Create a Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

**Branch naming conventions:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements

### 3. Make Changes

- Write clean, readable code
- Follow Rails conventions
- Add tests for new features
- Update documentation as needed
- Keep commits focused and atomic

### 4. Test Your Changes

```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/models/product_spec.rb

# Check code style
bundle exec rubocop

# Auto-fix style issues
bundle exec rubocop -a
```

### 5. Commit Your Changes

Write clear, descriptive commit messages:

```bash
# Good commit message
git commit -m "Add stock validation to cart items

- Prevent adding more items than available stock
- Show error message when limit reached
- Update cart UI to display available stock
- Add tests for stock validation"

# Bad commit message
git commit -m "fix bug"
```

**Commit message format:**
```
Short summary (50 chars or less)

Detailed explanation if needed:
- What changed
- Why it changed
- Any breaking changes
- Related issues (#123)
```

## Coding Standards

### Ruby Style

Follow the [Ruby Style Guide](https://rubystyle.guide/):

```ruby
# Good
def calculate_total
  items.sum(&:price)
end

# Bad
def calc_tot
  items.inject(0) { |sum, i| sum + i.price }
end
```

### Rails Conventions

```ruby
# Controllers - Keep thin
class ProductsController < ApplicationController
  def index
    @products = Product.all
  end
end

# Models - Business logic
class Product < ApplicationRecord
  validates :name, presence: true
  
  def display_price
    "#{currency} #{price}"
  end
end

# Services - Complex operations
class CartService
  def add_item(product_id, quantity: 1)
    # Implementation
  end
end
```

### Frontend

**HTML/ERB:**
```erb
<!-- Use semantic HTML -->
<article class="product-card">
  <h2><%= product.name %></h2>
  <p><%= product.description %></p>
</article>

<!-- Accessible forms -->
<%= form_with model: @product do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name, required: true %>
<% end %>
```

**Tailwind CSS:**
```html
<!-- Mobile-first, responsive -->
<div class="text-sm sm:text-base lg:text-lg">
  <h1 class="text-2xl sm:text-3xl font-bold">
    Title
  </h1>
</div>
```

**Stimulus:**
```javascript
// Clear, documented controllers
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  
  connect() {
    // Setup code
  }
  
  disconnect() {
    // Cleanup code
  }
}
```

### Code Quality

- **DRY** - Don't Repeat Yourself
- **KISS** - Keep It Simple, Stupid
- **YAGNI** - You Aren't Gonna Need It
- **Single Responsibility** - One class, one purpose
- **Meaningful Names** - Clear, descriptive variable/method names

## Testing

### Writing Tests

```ruby
# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'requires a name' do
      product = Product.new(name: nil)
      expect(product).not_to be_valid
    end
  end
  
  describe '#display_price' do
    it 'formats price with currency' do
      product = Product.new(price: 19.99, currency: 'USD')
      expect(product.display_price).to eq('USD 19.99')
    end
  end
end
```

### Test Coverage

- Aim for 80%+ coverage
- Test happy paths and edge cases
- Test error handling
- Test validations and associations

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/models/product_spec.rb

# Specific test
bundle exec rspec spec/models/product_spec.rb:10

# With coverage
COVERAGE=true bundle exec rspec
```

## Submitting Changes

### Before Submitting

Checklist:
- [ ] All tests pass
- [ ] No RuboCop violations
- [ ] Documentation updated
- [ ] Commits are clean and descriptive
- [ ] Branch is up to date with main

### Create Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open Pull Request**
   - Go to GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill in the template

3. **PR Description Template**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Tests added/updated
   - [ ] All tests passing
   - [ ] Manual testing completed
   
   ## Screenshots (if applicable)
   
   ## Related Issues
   Closes #123
   ```

### Code Review Process

1. **Automated Checks**
   - CI pipeline runs tests
   - Linting checks
   - Coverage reports

2. **Human Review**
   - Maintainer reviews code
   - Provides feedback
   - Requests changes if needed

3. **Address Feedback**
   - Make requested changes
   - Push updates to same branch
   - Respond to comments

4. **Merge**
   - Once approved, maintainer merges
   - Branch is deleted
   - Changes go live

## Reporting Issues

### Bug Reports

Include:
- **Description** - What happened?
- **Expected Behavior** - What should happen?
- **Steps to Reproduce** - How to trigger the bug?
- **Environment** - OS, Ruby version, browser
- **Screenshots** - If applicable
- **Error Messages** - Full stack trace

**Template:**
```markdown
**Bug Description**
Cart doesn't update when adding items

**Expected Behavior**
Cart should show updated quantity

**Steps to Reproduce**
1. Go to product page
2. Click "Add to Cart"
3. Open cart sidebar
4. Quantity doesn't update

**Environment**
- OS: macOS 14
- Ruby: 3.4.7
- Browser: Chrome 120

**Screenshots**
[Attach screenshot]

**Error Messages**
```
[Paste error]
```
```

### Feature Requests

Include:
- **Problem** - What problem does this solve?
- **Solution** - Proposed implementation
- **Alternatives** - Other approaches considered
- **Use Cases** - Who benefits and how?

## Community

### Communication Channels

- **GitHub Issues** - Bug reports and features
- **GitHub Discussions** - Questions and ideas
- **Nairuby Meetup** - Monthly community meetings
- **Slack/Discord** - Real-time chat (link in README)

### Getting Help

- Check [documentation](docs/)
- Search existing issues
- Ask in discussions
- Attend community meetings

### Recognition

Contributors are recognized in:
- README contributors section
- Release notes
- Community shoutouts

## Additional Resources

- [Rails Guides](https://guides.rubyonrails.org)
- [Ruby Style Guide](https://rubystyle.guide/)
- [Hotwire Documentation](https://hotwired.dev)
- [Tailwind CSS](https://tailwindcss.com)

## Questions?

Don't hesitate to ask! We're here to help:
- Open a discussion on GitHub
- Ask in community chat
- Email: info@nairuby.org

---

**Thank you for contributing to ARC Duka! 🎉**

Your contributions help support the African Ruby Community and make this project better for everyone.
