require "faraday"
require "base64"
require "json"

# Direct Safaricom Daraja client (M-Pesa Express / STK Push), bypassing Quikk.
# Quikk kept returning M-Pesa error 2029 ("Failed due to an unresolved reason
# type") on every charge against shortcode/till 3502158/4362425, in under a
# second (before any prompt reached the phone) — confirmed not a code or
# credentials issue on our side (see docs/DARAJA_SETUP.md). This talks to
# Safaricom directly with our own Daraja app credentials.
module Daraja
  class Client
    BASE_URL = Rails.env.production? ? "https://api.safaricom.co.ke" : "https://sandbox.safaricom.co.ke"

    def initialize
      creds = Rails.application.credentials.dig(:daraja) || {}
      @consumer_key    = creds[:consumer_key]
      @consumer_secret = creds[:consumer_secret]
      # short_code: the PayBill / Head Office number the Password is signed with.
      # till_no: set when receiving funds on a Buy Goods till. When present,
      # PartyB is the till (not short_code) and the transaction type switches
      # to CustomerBuyGoodsOnline — mismatching these is a classic cause of
      # M-Pesa rejecting STK requests outright.
      @shortcode    = creds[:shortcode]
      @till_no      = creds[:till_no]
      @passkey      = creds[:passkey]
      @callback_url = creds[:callback_url]
    end

    def stk_push(amount:, phone_number:, reference:, description:)
      token = access_token
      return error_result("Failed to obtain Daraja access token") unless token

      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      formatted_phone = format_phone(phone_number)

      post("/mpesa/stkpush/v1/processrequest", token, {
        BusinessShortCode: @shortcode,
        Password: password(timestamp),
        Timestamp: timestamp,
        TransactionType: transaction_type,
        Amount: amount.to_i,
        PartyA: formatted_phone,
        PartyB: party_b,
        PhoneNumber: formatted_phone,
        CallBackURL: @callback_url,
        AccountReference: reference,
        TransactionDesc: description
      })
    end

    # Reconciliation fallback for when a callback never arrives (network blip,
    # server down at the time, etc). ResultCode 0 = success; see
    # Mpesa::VerifyPaymentJob for how this is polled.
    def stk_query(checkout_request_id)
      token = access_token
      return error_result("Failed to obtain Daraja access token") unless token

      timestamp = Time.now.strftime("%Y%m%d%H%M%S")

      post("/mpesa/stkpushquery/v1/query", token, {
        BusinessShortCode: @shortcode,
        Password: password(timestamp),
        Timestamp: timestamp,
        CheckoutRequestID: checkout_request_id
      })
    end

    private

    def access_token
      # Daraja tokens last ~1hr. Caching avoids hitting /oauth/v1/generate on
      # every request, which otherwise risks tripping Safaricom's rate limiting
      # under repeated calls.
      Rails.cache.fetch("daraja_access_token_#{Rails.env}", expires_in: 55.minutes, skip_nil: true) do
        fetch_access_token
      end
    end

    def fetch_access_token
      auth = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")
      response = connection.get("/oauth/v1/generate?grant_type=client_credentials") do |req|
        req.headers["Authorization"] = "Basic #{auth}"
      end

      if response.body.blank?
        Rails.logger.error("Daraja OAuth: empty response body, HTTP #{response.status} (firewall drop or IP not whitelisted?)")
        return nil
      end

      unless response.success?
        Rails.logger.error("Daraja OAuth error #{response.status}: #{response.body}")
        return nil
      end

      JSON.parse(response.body)["access_token"]
    rescue JSON::ParserError => e
      Rails.logger.error("Daraja OAuth parse error: #{e.message} - body: #{response&.body}")
      nil
    end

    def post(path, token, body)
      response = connection.post(path) do |req|
        req.headers["Authorization"] = "Bearer #{token}"
        req.headers["Content-Type"] = "application/json"
        req.body = body.to_json
      end

      if response.body.blank?
        Rails.logger.error("Daraja #{path}: empty response body, HTTP #{response.status}")
        return error_result("Empty response from M-Pesa (#{response.status})")
      end

      result = JSON.parse(response.body)
      Rails.logger.error("Daraja #{path} error #{response.status}: #{result.inspect}") unless response.success?
      result
    rescue JSON::ParserError
      Rails.logger.error("Daraja #{path} unparseable response (#{response.status}): #{response.body}")
      error_result("Invalid response from M-Pesa (#{response.status})")
    end

    def error_result(message)
      { "ResponseCode" => "Error", "errorMessage" => message }
    end

    def password(timestamp)
      Base64.strict_encode64("#{@shortcode}#{@passkey}#{timestamp}")
    end

    def transaction_type
      @till_no.present? ? "CustomerBuyGoodsOnline" : "CustomerPayBillOnline"
    end

    def party_b
      @till_no.presence || @shortcode
    end

    def connection
      Faraday.new(url: BASE_URL) do |f|
        f.options.open_timeout = 10
        f.options.timeout = 15
      end
    end

    def format_phone(phone)
      PhoneNormalizer.normalize(phone, with_plus: false)
    end
  end
end
