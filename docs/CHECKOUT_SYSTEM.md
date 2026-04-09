# Checkout System Documentation

## Overview

The checkout system is a flexible, payment-agnostic architecture designed for the Kenyan market. It supports multiple payment methods and can easily integrate with various payment providers.

## Architecture

### Database Schema

#### Orders Table
- `order_number`: Unique identifier (e.g., ORD-20251122-A1B2C3D4)
- `user_id`: Optional - supports guest checkout
- `email`, `phone`: Contact information
- `status`: Order lifecycle (pending, confirmed, processing, shipped, delivered, cancelled)
- `payment_method`: card, bank_transfer, cash_on_delivery
- `payment_status`: pending, paid, failed, refunded
- `payment_reference`: External payment reference
- `subtotal`, `shipping_cost`, `total`: Pricing
- `currency`: Default KES (Kenyan Shilling)
- Shipping address fields
- `notes`: Customer notes

#### Order Items Table
- Links to Order, Product, and Variant
- Stores snapshot of product details at time of purchase
- `product_name`, `variant_details`: Preserved even if product changes
- `quantity`, `price`, `subtotal`

### Models

#### Order Model (`app/models/order.rb`)
**Key Features:**
- Generates unique order numbers automatically
- Calculates shipping costs based on location
- Status management with validations
- Factory method: `Order.create_from_cart(cart, user, params)`

**Status Flow:**
```
pending → confirmed → processing → shipped → delivered
         ↓
      cancelled
```

**Payment Status Flow:**
```
pending → paid
        ↓
      failed → refunded
```

**Methods:**
- `mark_as_paid!(payment_ref)`: Mark order as paid
- `mark_as_failed!`: Mark payment as failed
- `cancel!`: Cancel order (if eligible)
- `can_be_cancelled?`: Check if cancellation is allowed

#### OrderItem Model (`app/models/order_item.rb`)
- Automatically captures product snapshot on creation
- Calculates subtotal from price × quantity
- Preserves product/variant details for historical accuracy

### Controllers

#### CheckoutsController (`app/controllers/checkouts_controller.rb`)
**Actions:**
- `new`: Display checkout form
- `create`: Create order from cart
- `payment`: Show payment method selection
- `process_payment`: Handle payment method selection
- `confirmation`: Show order confirmation

**Flow:**
1. Customer fills shipping/contact info → `new`
2. Order created → `create`
3. Select payment method → `payment`
4. Process payment → `process_payment`
5. Show confirmation → `confirmation`

#### OrdersController (`app/controllers/orders_controller.rb`)
- `index`: List user's orders (requires authentication)
- `show`: View single order details

### Views

#### Checkout Form (`app/views/checkouts/new.html.erb`)
**Sections:**
- Contact Information (email, phone)
- Shipping Address (name, address, city, postal code, country)
- Order Notes (optional)
- Order Summary sidebar

**Features:**
- Responsive design
- Real-time cart summary
- Shipping cost preview
- Security badge

#### Payment Selection (`app/views/checkouts/payment.html.erb`)
**Payment Methods:**
#### 1. Card Payment - Visa/Mastercard
2. **Bank Transfer** - Direct bank transfer
3. **Cash on Delivery** - Pay when receiving order

**Features:**
- Visual payment method cards
- Order summary
- Shipping address confirmation

#### Order Confirmation (`app/views/checkouts/confirmation.html.erb`)
**Displays:**
- Order number and status
- Payment status
- Order items with images
- Totals breakdown
- Shipping and contact information
- Next steps information
- Action buttons (Continue Shopping, View Order)

## Shipping Cost Calculation

Current logic (can be customized):
```ruby
Nairobi: KES 200
Other Kenyan cities: KES 500
International: KES 1,500
```

Located in: `Order.calculate_shipping(order)`

## Payment Integration Points

### Ready for Integration

The system is designed to easily integrate with:

#### 1. Card Payments
**Options:**
- **Stripe** (International)
- **Paystack** (Africa-focused)
- **Flutterwave** (Africa-focused)

**Integration Point:**
- Add payment provider gem
- Create payment intent
- Redirect to payment page
- Handle webhook callbacks

#### 2. Bank Transfer
**Current Flow:**
- Shows bank details
- Manual verification by admin
- Admin marks as paid in Avo panel

#### 3. Cash on Delivery
**Current Flow:**
- Order confirmed immediately
- Payment collected on delivery
- Driver confirms payment

## Admin Panel Integration

### Order Management in Avo

**Features:**
- View all orders with filtering
- Search by order number, email, or phone
- Filter by status and payment status
- Update order status
- View order items
- Track payment references

**Filters:**
- Order Status (pending, confirmed, processing, shipped, delivered, cancelled)
- Payment Status (pending, paid, failed, refunded)
- Payment Method

**Actions:**
- Edit order details
- Update status
- Add notes
- View customer information

## Guest Checkout

The system supports guest checkout:
- `user_id` is optional on orders
- Email and phone captured for communication
- Guest orders can be claimed by users later (future feature)

## Security Features

- CSRF protection on all forms
- Email validation
- Phone number validation
- Order access control (users can only view their own orders)
- Admin-only order management

## Future Enhancements

### Recommended Next Steps

1. **Email Notifications**
   - Order confirmation emails
   - Shipping notifications
   - Payment receipts
   - Delivery confirmations

2. **Order Tracking**
   - Tracking number integration
   - Status update notifications
   - Estimated delivery dates

3. **Inventory Management**
   - Reduce stock on order confirmation
   - Restore stock on cancellation
   - Low stock alerts

4. **Customer Account Features**
   - Order history page
   - Saved addresses
   - Reorder functionality
   - Order cancellation requests

5. **Advanced Shipping**
   - Multiple shipping methods
   - Real-time shipping quotes
   - Courier integration (DHL, Posta Kenya, etc.)

6. **Payment Features**
   - Partial payments
   - Payment plans
   - Refund processing
   - Multiple payment methods per order

## Testing

### Manual Testing Checklist

- [ ] Add items to cart
- [ ] Proceed to checkout
- [ ] Fill shipping information
- [ ] Select payment method
- [ ] Complete order
- [ ] View confirmation
- [ ] Check order in admin panel
- [ ] Test guest checkout
- [ ] Test authenticated checkout
- [ ] Test each payment method
- [ ] Test order cancellation

### Test Data

Create test order:
```ruby
rails console
cart = Cart.new(session_data)
user = User.first
order = Order.create_from_cart(cart, user, {
  email: 'test@example.com',
  phone: '+254700000000',
  shipping_name: 'Test User',
  shipping_address: '123 Test Street',
  shipping_city: 'Nairobi',
  shipping_country: 'Kenya'
})
```

## Routes

```
GET    /checkout/new              - Checkout form
POST   /checkout                  - Create order
GET    /checkout/payment          - Payment selection
POST   /checkout/process_payment  - Process payment
GET    /orders/:id/confirmation   - Order confirmation
GET    /orders                    - Order history (authenticated)
GET    /orders/:id                - View order
```

## Configuration

### Currency
Default: KES (Kenyan Shilling)
Change in: `Order` model default value

### Shipping Costs
Modify: `Order.calculate_shipping` method

### Payment Methods
Add/remove in: `Order::PAYMENT_METHODS` constant

### Order Statuses
Modify: `Order::STATUSES` constant

## Support

For questions or issues:
1. Check this documentation
2. Review the code comments
3. Contact the development team

## Payment Provider Resources

### Card Payments
- [Stripe Documentation](https://stripe.com/docs)
- [Paystack Documentation](https://paystack.com/docs)
- [Flutterwave Documentation](https://developer.flutterwave.com/)

### Testing
- Use sandbox/test modes for all payment providers
- Never use real payment credentials in development
- Test all payment flows before going live
