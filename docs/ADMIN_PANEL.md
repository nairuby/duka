# ARC Duka Admin Panel

## Overview

The admin panel is built using [Avo](https://avohq.io/), a beautiful admin panel framework for Ruby on Rails. It provides a comprehensive interface for managing products, variants, and stock levels.

## Access

### Admin Panel
**URL:** `/avo`

### Login Page
**URL:** `/users/sign_in`

**Default Admin Credentials:**
- Email: `admin@arcduka.com`
- Password: `password123`

⚠️ **Important:** Change the default password immediately in production!

### Login UI Features
- Beautiful, branded login interface with ARC Duka styling
- Responsive design for mobile and desktop
- Auto-dismissing flash messages for success/error notifications
- "Remember me" functionality
- Password reset flow
- Direct link back to the store
- Smooth animations and transitions

## Features

### Dashboard
- **Stock Overview**: View key metrics at a glance
  - Total Products
  - Total Variants
  - Low Stock Alerts (< 10 items)
  - Out of Stock Items

### Product Management
- Create, edit, and delete products
- Fields:
  - Name (required)
  - Description
  - Price (required)
  - Currency (USD, KES, EUR, GBP)
  - Category (Shirts, Hoodies, Hats, Bags, Mugs, Stickers, Accessories)
  - Image URL
- Search products by name or description
- Filter by category
- Sort by name, price, or date

### Variant Management
- Manage product variants (size, color, SKU)
- Track stock quantities
- Fields:
  - Product (required)
  - SKU (required, unique)
  - Size (required)
  - Color (required)
  - Stock Quantity (required, min: 0)
- Search variants by SKU, size, or color
- Filter by stock status:
  - Low Stock (< 10 items)
  - Out of Stock
  - In Stock
- Sort by any field

### User Management
- View and manage users
- Grant/revoke admin privileges
- Search users by email

## Authentication & Authorization

- Only users with `admin: true` can access the admin panel
- Non-admin users are redirected to the homepage with an error message
- Uses Devise for authentication

## Creating Additional Admin Users

### Via Rails Console
```ruby
rails console
User.create!(
  email: 'newadmin@example.com',
  password: 'securepassword',
  password_confirmation: 'securepassword',
  admin: true
)
```

### Via Admin Panel
1. Log in to `/avo`
2. Navigate to Users
3. Click "Create new user"
4. Fill in email and check the "Admin" checkbox
5. Save

## Stock Management Workflow

1. **Add Products**: Create products with basic information
2. **Add Variants**: For each product, create variants with different sizes/colors
3. **Set Stock Levels**: Assign stock quantities to each variant
4. **Monitor Dashboard**: Check the dashboard regularly for low stock alerts
5. **Update Stock**: Edit variant stock quantities as inventory changes

## Tips

- Use the search feature to quickly find products or variants
- Apply filters to focus on specific categories or stock levels
- The dashboard provides a quick overview of your inventory health
- Low stock alerts help you reorder before running out

## Security Notes

- Always use strong passwords for admin accounts
- Limit admin access to trusted personnel only
- Regularly audit admin user list
- Consider enabling two-factor authentication in production

## Support

For issues or questions about the admin panel, contact your development team.
