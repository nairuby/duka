require "base64"
require "net/http"
require "openssl"
require "json"
require "time"

module Quikk
  class Client
    BASE_URL = "https://tryapi.quikk.dev/v1"

    def initialize(api_key = nil, api_secret = nil)
      @api_key = api_key || Rails.application.credentials.dig(:quikk, :api_key)
      @api_secret = api_secret || Rails.application.credentials.dig(:quikk, :api_secret)
      @shortcode = Rails.application.credentials.dig(:quikk, :shortcode)
    end

    def charge(amount:, phone_number:, reference:, description:)
      payload = {
        data: {
          type: "charge",
          id: reference,
          attributes: {
            amount: amount.to_i,
            customer_type: "msisdn",
            customer_no: format_phone(phone_number),
            short_code: @shortcode.to_s,
            reference: reference,
            posted_at: Time.now.utc.iso8601(6)
          }
        }
      }
      post("/mpesa/charge", payload)
    end

    def search(request_id)
      get("/mpesa/search/#{request_id}")
    end

    def verify_signature(body, signature)
      return false if signature.blank? || @api_secret.blank?
      expected = Base64.strict_encode64(
        OpenSSL::HMAC.digest("SHA256", @api_secret, body)
      )
      ActiveSupport::SecurityUtils.secure_compare(expected, signature)
    end

    private

    def post(path, payload)
      uri = URI.parse("#{BASE_URL}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 15

      request_date = Time.now.httpdate
      request_body = payload.to_json
      headers = build_headers(request_date)
      request = Net::HTTP::Post.new(uri, headers)
      request.body = request_body

      Rails.logger.debug("Quikk POST #{uri} | Body: #{request.body}")
      Rails.logger.debug("Quikk Headers | Date: #{headers['Date']} | Authorization: #{headers['Authorization']}")
      execute_with_retries { http.request(request) }
    end

    def get(path)
      uri = URI.parse("#{BASE_URL}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 15

      request_date = Time.now.httpdate
      headers = build_headers(request_date)
      request = Net::HTTP::Get.new(uri, headers)
      Rails.logger.debug("Quikk Headers | Date: #{headers['Date']} | Authorization: #{headers['Authorization']}")

      execute_with_retries { http.request(request) }
    end

    def build_headers(request_date)
      x_custom = "custom"
      {
        "Content-Type" => "application/vnd.api+json",
        "Accept" => "application/vnd.api+json",
        "Date" => request_date,
        "X-Custom" => x_custom,
        "Authorization" => build_authorization(request_date, x_custom)
      }
    end

    def build_authorization(request_date, x_custom)
      signing_string = "date: #{request_date}\nx-custom: #{x_custom}"

      raw_signature = Base64.strict_encode64(
        OpenSSL::HMAC.digest("SHA256", @api_secret, signing_string)
      )
      url_encoded_signature = URI.encode_www_form_component(raw_signature)

      Rails.logger.debug("Quikk signing string: #{signing_string}")
      Rails.logger.debug("Quikk signature (raw): #{raw_signature}")
      Rails.logger.debug("Quikk signature (url-encoded): #{url_encoded_signature}")

      "keyId=\"#{@api_key}\",algorithm=\"hmac-sha256\",headers=\"date x-custom\",signature=\"#{url_encoded_signature}\""
    end

    def format_phone(phone)
      PhoneNormalizer.normalize(phone, with_plus: false)
    end

    def execute_with_retries(max_retries = 3)
      retry_count = 0
      begin
        response = yield
        handle_response(response)
      rescue Net::ReadTimeout, Net::OpenTimeout, Errno::ECONNREFUSED => e
        if retry_count < max_retries
          retry_count += 1
          sleep(2 ** retry_count)
          retry
        else
          raise e
        end
      end
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        JSON.parse(response.body)
      else
        Rails.logger.error("Quikk API Error: #{response.code} - #{response.body}")
        JSON.parse(response.body) rescue { "error" => "Unknown error", "status" => response.code }
      end
    end
  end
end
