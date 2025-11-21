# Test Suite - Milestone 1

## Overview

This test suite covers the foundational UI components for the African Ruby Community e-commerce landing page.

## Test Structure

### Request Specs (`spec/requests/home_spec.rb`)
Tests the HTTP layer to ensure the home page responds correctly:
- Returns 200 OK status
- Renders successfully
- Includes expected content

### View Specs (`spec/views/home/index_spec.rb`)
Tests the view templates in isolation:
- Landing page partial renders
- All sections are included

### System Specs (`spec/system/landing_page_spec.rb`)
End-to-end tests simulating user interactions:

#### Navbar Tests
- ✅ African Ruby branding displays
- ✅ Navigation links present (About Us, Community, Contact)
- ✅ Shopping cart icon visible
- ✅ Search icon visible

#### Hero Section Tests
- ✅ Main headline displays ("Wear Your Ruby Pride")
- ✅ Description text present
- ✅ CTA buttons (Shop Collection, Join Community)

#### Categories Section Tests
- ✅ Category grid displays
- ✅ All 4 categories shown (Apparel, Drinkware, Accessories, Limited Edition)
- ✅ Category icons present

#### Products Section Tests
- ✅ Products heading displays
- ✅ All 6 product cards shown
- ✅ Product prices displayed
- ✅ Add to Cart buttons present

#### Footer Tests
- ✅ African Ruby branding in footer
- ✅ Footer navigation sections
- ✅ Copyright information
- ✅ Social media links

#### Responsive Design Tests
- ✅ Mobile menu button present

## Running Tests

### Run all tests:
```bash
bundle exec rspec
```

### Run specific test file:
```bash
bundle exec rspec spec/requests/home_spec.rb
bundle exec rspec spec/views/home/index_spec.rb
bundle exec rspec spec/system/landing_page_spec.rb
```

### Run with documentation format:
```bash
bundle exec rspec --format documentation
```

### Run with coverage (if SimpleCov is configured):
```bash
COVERAGE=true bundle exec rspec
```

## Test Results

**Total: 24 examples, 0 failures**

- Request specs: 3 examples
- View specs: 2 examples  
- System specs: 19 examples

## What's Tested

✅ **Core UI Components:**
- Navbar with branding and navigation
- Hero section with headline and CTAs
- Category grid with 4 categories
- Products section with 6 items
- Footer with links and branding

✅ **Functionality:**
- Page loads successfully
- All content renders
- Navigation elements present
- Interactive elements (buttons, links) exist

## What's NOT Tested (Future Milestones)

❌ JavaScript interactions (mobile menu toggle, dropdowns)
❌ Product filtering by category
❌ Shopping cart functionality
❌ Form submissions
❌ Database interactions
❌ User authentication

These will be added in Milestone 2 and beyond.

## Notes

- Tests use `rack_test` driver (no JavaScript)
- Selenium/browser tests skipped (requires browser setup)
- Tests focus on content presence, not styling
- All tests are fast and don't require external services
