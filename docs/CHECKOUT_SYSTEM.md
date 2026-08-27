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

### Quikk Webhook Callback (Tunnel Testing)

For local testing via Cloudflare Tunnel, set Quikk callback/webhook URL to your public tunnel domain plus the Rails webhook path:

`https://<your-tunnel-domain>/payments/callback`

Example used in this project:

`https://cab-bool-wmam-furnished.trycloudflare.com/payments/callback`

Route reference:
- `POST /payments/callback` → `webhooks#quikk` (`config/routes.rb`)

Quikk API docs:
- https://app.swaggerhub.com/apis/zegetech/Handaki/1.0#/

### Quikk Integration Playbook (Reusable Across Apps)

Use this section as the standard implementation blueprint for other ecommerce apps and fintech solutions.

#### 1. Required Routes

Add a webhook callback endpoint:

```ruby
post "payments/callback", to: "webhooks#quikk"
```

Add a payment status polling endpoint for customer UI:

```ruby
get "checkout/mpesa_status/:id", to: "checkouts#mpesa_status", as: :mpesa_status_checkout
```

#### 2. Required Order Fields

Your order/payment aggregate should have:
- `payment_method`
- `payment_status` (`pending`, `started`, `paid`, `failed`, etc.)
- `quikk_request_id`
- `payment_initiated_at`
- `payment_completed_at`
- `mpesa_receipt` (optional but useful)

#### 3. Outbound Charge Request (Quikk Client)

Current working request shape:

```json
{
  "data": {
    "type": "charge",
    "id": "ORDER-<order-id>",
    "attributes": {
      "amount": 1,
      "customer_type": "msisdn",
      "customer_no": "2547XXXXXXXX",
      "short_code": "174379",
      "reference": "ORDER-<order-id>",
      "posted_at": "2026-05-24T02:00:22.566284Z"
    }
  }
}
```

#### 4. Quikk HMAC Authentication (Working Profile)

Headers used in this project:
- `Date: <HTTP GMT date>`
- `X-Custom: custom`
- `Authorization: keyId="...",algorithm="hmac-sha256",headers="date x-custom",signature="..."`

Signing string:

```text
date: <Date header value>
x-custom: custom
```

Signature generation:
- HMAC-SHA256 with API secret
- Base64 encode raw digest
- URL-encode base64 output before placing in `Authorization` header

Implementation location:
- `app/services/quikk/client.rb`

#### 5. Webhook Parsing Rules (Important for Portability)

Quikk callback payloads can vary by product flow. Do not assume only one identifier field.

Always handle these IDs:
- `data.id` (can be `ORDER-<order-id>` or provider-generated)
- `attributes.txn_charge_id` (often matches your stored `quikk_request_id`)
- `attributes.resource_id`
- `attributes.response_id`

Order lookup strategy:
1. Try `quikk_request_id` using all non-empty callback IDs.
2. If `data.id` starts with `ORDER-`, extract UUID and find by order id.

Phone number mapping for callback transaction record:
- `attributes.customer_no || attributes.sender_no`

Status mapping strategy:
- Success if `txn_status` in `SUCCESS|SUCCESSFUL|COMPLETED|PAID`
- Failure if `txn_status` in `FAILED|FAIL|ERROR|DECLINED|CANCELLED|CANCELED`
- Fallback: if `txn_status` missing and `txn_id` present, treat as success

Implementation location:
- `app/controllers/webhooks_controller.rb`

#### 6. Customer Polling UX Pattern

Polling endpoint should return JSON with order payment status:

```json
{ "status": "paid", "payment_status": "pending" }
```

Frontend behavior:
- If `status == "paid"`: redirect to confirmation page
- If `status == "failed"`: redirect to payment retry page
- Else keep polling for a bounded period

Implementation locations:
- `app/controllers/checkouts_controller.rb` (`mpesa_status`)
- `app/javascript/controllers/mpesa_polling_controller.js`

#### 7. Environment Configuration Contract

For each environment, define:
- `quikk.api_key`
- `quikk.api_secret`
- `quikk.shortcode`

Use test credentials with:
- `https://tryapi.quikk.dev/v1`

Use production credentials with:
- `https://api.quikk.dev/v1`

#### 8. Operations and Maintainability Standards (Open Source Friendly)

Adopt these standards so teams can maintain this integration long-term:
- Keep all provider-specific logic in `app/services/quikk/client.rb`.
- Keep webhook normalization/mapping in one controller method.
- Use clear logs with stable prefixes (`Quikk POST`, `Quikk Webhook Payload`, `Order not found...`).
- Avoid hardcoding business behavior in JS; source truth remains server `payment_status`.
- Add regression tests for:
  - callback with `data.id = ORDER-<id>`
  - callback with only `txn_charge_id`
  - callback with missing `txn_status` but present `txn_id`
  - callback idempotency (already paid order)

#### 9. Copy-Paste Checklist for New Apps

- [ ] Add routes for charge polling and callback webhook.
- [ ] Add order/payment fields and indexes.
- [ ] Copy Quikk client service (`client.rb`) and update credential source.
- [ ] Copy webhook controller callback mapping logic.
- [ ] Copy frontend polling controller and status page wiring.
- [ ] Configure public callback URL in Quikk dashboard.
- [ ] Test end-to-end with sandbox tunnel URL.
- [ ] Validate idempotency and retry behavior.
- [ ] Remove sensitive debug logging in production.

### Incident Report: STK Wait Page Stuck After Successful Payment

#### Summary

The payment could complete on M-Pesa, but the user remained on the "Waiting for payment confirmation" page.

#### Actual Cause

- Quikk callback reached `POST /payments/callback`, but webhook processing crashed before updating `order.payment_status`.
- Main crash: `success_status?` was called with the wrong number of arguments, causing an exception and transaction rollback.
- Additional payload mapping mismatches:
  - callback used `sender_no` while code expected `customer_no`
  - callback identifiers varied (`data.id`, `txn_charge_id`, `resource_id`, `response_id`)
  - some success callbacks had no `txn_status`, only `txn_id`

#### Impact

- Order stayed at `payment_status = started`
- Polling endpoint never returned `paid`
- Frontend polling controller never redirected to confirmation

#### Fix Applied

- Corrected `success_status?` call signature
- Normalized callback ID lookup across `data.id`, `txn_charge_id`, `resource_id`, `response_id`, and `ORDER-<uuid>` fallback
- Mapped phone field as `customer_no || sender_no`
- Improved success/failure resolution:
  - success for `SUCCESS|SUCCESSFUL|COMPLETED|PAID`
  - failure for `FAILED|FAIL|ERROR|DECLINED|CANCELLED|CANCELED`
  - fallback success when `txn_id` exists and `txn_status` is missing

#### Prevention

- Keep provider-specific callback normalization centralized in `WebhooksController`
- Add regression tests for callback payload variants and idempotency
- Keep temporary auth/debug logs only during troubleshooting

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
