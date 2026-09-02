# Quikk API Setup

## Overview

This guide covers how to configure Quikk payments for this app, including credentials, API base URL, webhook callback, request signing, and verification.

Reference API docs:
- https://app.swaggerhub.com/apis/zegetech/Handaki/1.0#/

## 1. Configure Credentials

Set these credentials per environment:

- `quikk.api_key`
- `quikk.api_secret`
- `quikk.shortcode`

Expected endpoints:

- Sandbox/Test: `https://tryapi.quikk.dev/v1`
- Production: `https://api.quikk.dev/v1`

In this codebase, Quikk integration is implemented in:

- `app/services/quikk/client.rb`

## 2. Configure Routes

Ensure these routes exist:

```ruby
post "payments/callback", to: "webhooks#quikk"
get "checkout/mpesa_status/:id", to: "checkouts#mpesa_status", as: :mpesa_status_checkout
```

Purpose:

- `POST /payments/callback`: receives Quikk payment webhooks.
- `GET /checkout/mpesa_status/:id`: supports frontend polling while waiting for payment completion.

## 3. Set Quikk Webhook URL

In Quikk dashboard/settings, set callback URL to:

`https://<your-public-domain>/payments/callback`

For local development with a tunnel:

`https://<your-tunnel-domain>/payments/callback`

Example:

`https://cab-bool-wmam-furnished.trycloudflare.com/payments/callback`

## 4. Send Charge Request

Typical request payload shape:

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

Recommended:

- Keep `data.id` and `reference` tied to your internal order identifier (for example: `ORDER-<order-id>`).
- Store provider request/charge IDs on your order (`quikk_request_id`) for webhook reconciliation.

## 5. Configure HMAC Authentication

Required request headers:

- `Date: <HTTP GMT date>`
- `X-Custom: custom`
- `Authorization: keyId="...",algorithm="hmac-sha256",headers="date x-custom",signature="..."`

Example:

```http
Date: Mon, 25 May 2026 09:15:42 GMT
X-Custom: custom
Authorization: keyId="YOUR_API_KEY",algorithm="hmac-sha256",headers="date x-custom",signature="QmFzZTY0U2lnbmF0dXJlJTNE"
```

Signing string (must match header values exactly):

```text
date: <Date header value>
x-custom: custom
```

Signature process:

1. HMAC-SHA256 sign using `quikk.api_secret`.
2. Base64 encode the raw digest.
3. URL-encode the base64 result before adding it to `Authorization`.

Ruby reference:

```ruby
request_date = Time.now.httpdate
x_custom = "custom"
signing_string = "date: #{request_date}\nx-custom: #{x_custom}"

raw_signature = Base64.strict_encode64(
  OpenSSL::HMAC.digest("SHA256", quikk_api_secret, signing_string)
)
encoded_signature = URI.encode_www_form_component(raw_signature)

authorization = "keyId=\"#{quikk_api_key}\",algorithm=\"hmac-sha256\",headers=\"date x-custom\",signature=\"#{encoded_signature}\""
```

Important:

- The `Date` value in the header must be the exact value used in `signing_string`.
- Header list in `Authorization` must remain `headers="date x-custom"`.
- Do not send raw base64 signature without URL-encoding.
- Use GMT HTTP date format (`Time.now.httpdate` in Ruby).

### HMAC Header Generation Scripts

Use one of these scripts to generate auth headers for manual API tests.

Bash (`openssl` + `base64` + `jq`):

```bash
#!/usr/bin/env bash
set -euo pipefail

API_KEY="${QUIKK_API_KEY:?set QUIKK_API_KEY}"
API_SECRET="${QUIKK_API_SECRET:?set QUIKK_API_SECRET}"
X_CUSTOM="custom"
DATE_HEADER="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S GMT')"

SIGNING_STRING="date: ${DATE_HEADER}"$'\n'"x-custom: ${X_CUSTOM}"
RAW_SIGNATURE="$(printf '%s' "$SIGNING_STRING" | openssl dgst -sha256 -hmac "$API_SECRET" -binary | base64)"
ENCODED_SIGNATURE="$(printf '%s' "$RAW_SIGNATURE" | jq -sRr @uri)"

AUTH_HEADER="keyId=\"${API_KEY}\",algorithm=\"hmac-sha256\",headers=\"date x-custom\",signature=\"${ENCODED_SIGNATURE}\""

echo "Date: ${DATE_HEADER}"
echo "X-Custom: ${X_CUSTOM}"
echo "Authorization: ${AUTH_HEADER}"
```

Ruby (standalone script):

```ruby
#!/usr/bin/env ruby
require "openssl"
require "base64"
require "uri"
require "time"

api_key = ENV.fetch("QUIKK_API_KEY")
api_secret = ENV.fetch("QUIKK_API_SECRET")
x_custom = "custom"
date_header = Time.now.httpdate

signing_string = "date: #{date_header}\nx-custom: #{x_custom}"
raw_signature = Base64.strict_encode64(
  OpenSSL::HMAC.digest("SHA256", api_secret, signing_string)
)
encoded_signature = URI.encode_www_form_component(raw_signature)

authorization = "keyId=\"#{api_key}\",algorithm=\"hmac-sha256\",headers=\"date x-custom\",signature=\"#{encoded_signature}\""

puts "Date: #{date_header}"
puts "X-Custom: #{x_custom}"
puts "Authorization: #{authorization}"
```

Quick `curl` usage pattern:

```bash
curl -X POST "https://tryapi.quikk.dev/v1/mpesa/charge" \
  -H "Content-Type: application/vnd.api+json" \
  -H "Accept: application/vnd.api+json" \
  -H "Date: ${DATE_HEADER}" \
  -H "X-Custom: custom" \
  -H "Authorization: ${AUTH_HEADER}" \
  --data '{"data":{"type":"charge","id":"ORDER-123","attributes":{"amount":1,"customer_type":"msisdn","customer_no":"2547XXXXXXXX","short_code":"174379","reference":"ORDER-123","posted_at":"2026-05-25T09:15:42.000000Z"}}}'
```

## 6. Handle Webhook Variants Safely

**Quikk does not sign the charge callback.** The Handaki spec defines no signature
scheme or auth header on the `onData` callback, so there is nothing to HMAC-verify
on inbound requests (the HMAC in section 5 is for *outbound* calls only). The
callback endpoint is protected by requiring the payload to resolve to an order we
actually initiated — an unmatched callback is rejected with `404` and never
mutates an order. Optionally add an IP allowlist for Quikk's egress range.

Quikk callbacks may provide different ID fields depending on flow. Parse all when present:

- `data.id`
- `attributes.txn_charge_id`
- `attributes.resource_id`
- `attributes.response_id`

Order lookup strategy:

1. First match known callback IDs against stored `quikk_request_id`.
2. If `data.id` starts with `ORDER-`, extract order id and match internal order.

Phone field fallback:

- Use `attributes.customer_no || attributes.sender_no`.

Status mapping:

- Success: `txn_status` in `SUCCESS|SUCCESSFUL|COMPLETED|PAID`
- Failure: `txn_status` in `FAILED|FAIL|ERROR|DECLINED|CANCELLED|CANCELED`, or `meta.status` in `FAIL|FAILED|ERROR`
- Fallback: real Quikk success callbacks omit `txn_status` — if `attributes.txn_id` is present, treat as success.

Receipt: use `attributes.mpesa_receipt || attributes.receipt || attributes.txn_id`
(Quikk's success callback carries the M-Pesa receipt in `txn_id`).

Webhook controller location:

- `app/controllers/webhooks_controller.rb`

## 7. Frontend Polling Contract

Polling response example:

```json
{ "status": "paid", "payment_status": "pending" }
```

Expected UI behavior:

- If `status == "paid"`: redirect to confirmation page.
- If `status == "failed"`: redirect to retry page.
- Otherwise: continue polling for a bounded time.

Implementation:

- `app/controllers/checkouts_controller.rb` (`mpesa_status`)
- `app/javascript/controllers/mpesa_polling_controller.js`

## 8. Setup Checklist

- [ ] Add Quikk credentials for current environment.
- [ ] Confirm API base URL (sandbox vs production).
- [ ] Ensure callback and polling routes are present.
- [ ] Set callback URL in Quikk dashboard.
- [ ] Trigger a sandbox payment request.
- [ ] Verify webhook reaches `POST /payments/callback`.
- [ ] Confirm order transitions to paid/failed correctly.
- [ ] Verify polling flow redirects user from waiting screen.
- [ ] Test idempotency by replaying callback payload.

## 9. Troubleshooting

If payment succeeds on M-Pesa but checkout stays on waiting screen:

- Check webhook logs for exceptions in `WebhooksController#quikk`.
- Verify callback IDs map to either `quikk_request_id` or `ORDER-<id>`.
- Ensure status mapping handles your callback payload variant.
- Confirm polling endpoint returns updated status after callback processing.
