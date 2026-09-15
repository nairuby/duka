# Daraja (M-Pesa) API Setup

Direct Safaricom Daraja integration for STK Push, replacing Quikk as the M-Pesa
provider. Implemented in `app/services/daraja/client.rb`.

## Why not Quikk

Quikk (`app/services/quikk/client.rb`, `docs/QUIKK_API_SETUP.md`) is still in
the codebase but no longer wired to checkout. Every production charge against
shortcode `3502158` / till `4362425` returned M-Pesa error `2029 — "Failed due
to an unresolved reason type"` in under a second (before any STK prompt
reached the phone), including after sending the correct `till_no` per Quikk's
own API schema. That ruled out app-side bugs and credentials — confirmed via:
worker running and healthy, Quikk auth succeeding (`api.quikk.dev` accepted
the request and returned a real `CheckoutRequestID`), callback arriving and
processed correctly, `till_no`/`shortcode` both verified live on the deployed
release. The failure is on Quikk's/Safaricom's side of that specific
merchant account and wasn't resolved through the API. See
`ws_CO_14092026235611482790337921` for the reference failed transaction if
following up with Quikk support.

## 1. Configure Credentials

Rails encrypted credentials, same pattern as Quikk — **not** ENV vars:

```bash
EDITOR=vi bin/rails credentials:edit --environment development
EDITOR=vi bin/rails credentials:edit --environment production
```

```yaml
daraja:
  consumer_key: <Daraja app Consumer Key>
  consumer_secret: <Daraja app Consumer Secret>
  shortcode: <PayBill / Head Office number the Password is signed with>
  till_no: <Buy Goods till number, if receiving on a till — omit for a pure PayBill>
  passkey: <Lipa Na M-Pesa Online passkey for this shortcode>
  callback_url: https://<host>/payments/mpesa/callback
```

`shortcode` vs `till_no` matters: if `till_no` is set, `PartyB` is the till
and `TransactionType` is `CustomerBuyGoodsOnline`; `BusinessShortCode` (used
to sign the `Password`) is always `shortcode`. Passing a shortcode/till pair
that don't correspond to a real Head-Office/Store link on Safaricom's side is
the classic cause of instant STK rejections ("Agent number and Store number
entered do not match", or a generic code like Quikk's `2029`).

For local development against the Daraja **sandbox**
(`https://sandbox.safaricom.co.ke`), Safaricom's well-known test values work:
shortcode `174379`, passkey
`bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919`. Get a
Consumer Key/Secret by creating an app at
https://developer.safaricom.co.ke against the "Lipa Na M-Pesa Sandbox" API.

## 2. Register the Callback URL

In the Daraja app / Lipa Na M-Pesa Online settings on
https://developer.safaricom.co.ke (and again for the production app), set the
callback URL to:

```
https://<your-domain>/payments/mpesa/callback
```

For local development, use a tunnel (cloudflared/ngrok) the same way
`docs/QUIKK_API_SETUP.md` describes for Quikk.

## 3. Request / Callback Shapes

STK Push request (`app/services/daraja/client.rb#stk_push`) — standard Daraja
`POST /mpesa/stkpush/v1/processrequest`:

```json
{
  "BusinessShortCode": "174379",
  "Password": "<base64(shortcode+passkey+timestamp)>",
  "Timestamp": "20260914205611",
  "TransactionType": "CustomerBuyGoodsOnline",
  "Amount": 1,
  "PartyA": "254712345678",
  "PartyB": "4362425",
  "PhoneNumber": "254712345678",
  "CallBackURL": "https://shop.rubycommunity.africa/payments/mpesa/callback",
  "AccountReference": "ORD-A1B2C3D4",
  "TransactionDesc": "Payment for Order ORD-A1B2C3D4"
}
```

Callback (`WebhooksController#mpesa`) — `Body.stkCallback`:

```json
{
  "Body": {
    "stkCallback": {
      "MerchantRequestID": "29115-34620561-1",
      "CheckoutRequestID": "ws_CO_191220191020363925",
      "ResultCode": 0,
      "ResultDesc": "The service request is processed successfully.",
      "CallbackMetadata": {
        "Item": [
          { "Name": "Amount", "Value": 1.00 },
          { "Name": "MpesaReceiptNumber", "Value": "NLJ7RT61SV" },
          { "Name": "TransactionDate", "Value": 20260914102115 },
          { "Name": "PhoneNumber", "Value": 254712345678 }
        ]
      }
    }
  }
}
```

`ResultCode != 0` means failure; `CallbackMetadata` is absent on failure.
**Daraja does not sign this callback** (same as Quikk) — the endpoint is
protected by requiring `CheckoutRequestID` to match an order we actually
initiated (`Order#quikk_request_id`, which is provider-agnostic despite the
name — it holds whichever provider's request id, Quikk's or Daraja's).

## 4. Reconciliation Fallback

`Mpesa::VerifyPaymentJob` polls `POST /mpesa/stkpushquery/v1/query` (via
`Daraja::Client#stk_query`) starting 20s after the charge, retrying every 20s
up to `MAX_ATTEMPTS` (6 — about 2 minutes), only for orders still stuck at
`payment_status: "started"`. This is the safety net for a lost callback; it
does not run at all if the callback already resolved the order. Note the
Query endpoint does not return the M-Pesa receipt number — an order marked
paid this way has a nil `mpesa_receipt` unless the callback later arrives too.

## 5. Worker Health

Both the charge (`Mpesa::ChargeJob`) and reconciliation run on Solid Queue —
see `docs/DEPLOYMENT.md`. `GET /healthz/jobs` returns 503 if no worker has
heartbeated in the last 2 minutes; point an uptime monitor at it. This is
mitigation for exactly what went wrong before: the worker died with no
customer-facing error and nobody noticed for days.

## 6. Rollback

Quikk's code (`app/services/quikk/client.rb`, `WebhooksController#quikk`,
`post "payments/callback"`) is left in place, dormant. To roll back, point
`Mpesa::ChargeJob` at `Quikk::Client` again instead of `Daraja::Client`.
