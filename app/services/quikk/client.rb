module Quikk
  class Client
    BASE_URL = "https://api.quikk.mobi"
    
    def initialize(api_key = nil, api_secret = nil)
      @api_key = api_key || Rails.application.credentials.dig(:quikk, :api_key)
      @api_secret = api_secret || Rails.application.credentials.dig(:quikk, :api_secret)
      @shortcode = Rails.application.credentials.dig(:quikk, :shortcode)
    end

    def charge(amount:, phone_number:, reference:, description:)
      payload = {
        amount: amount.to_i,
        phoneNumber: format_phone(phone_number),
        reference: reference,
        description: description,
        shortcode: @shortcode
      }

      post("/payments/charge", payload)
    end

    def search(request_id)
      get("/payments/search/#{request_id}")
    end

    def verify_signature(body, signature)
      return false if signature.blank? || @api_secret.blank?
      
      expected_signature = OpenSSL::HMAC.hexdigest('SHA256', @api_secret, body)
      ActiveSupport::SecurityUtils.secure_compare(expected_signature, signature)
    end

    private

    def post(path, payload)
      uri = URI.parse("#{BASE_URL}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri, headers)
      request.body = payload.to_json
      
      execute_with_retries do
        http.request(request)
      end
    end

    def get(path)
      uri = URI.parse("#{BASE_URL}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri, headers)
      
      execute_with_retries do
        http.request(request)
      end
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}",
        'X-Quikk-API-Key' => @api_key,
        'Accept' => 'application/json'
      }
    end

    def format_phone(phone)
      digits = phone.to_s.gsub(/\D/, '')
      if digits.start_with?('0')
        digits.sub(/^0/, '254')
      elsif digits.start_with?('254')
        digits
      else
        "254#{digits}"
      end
    end

    def execute_with_retries(max_retries = 3)
      retry_count = 0
      begin
        response = yield
        handle_response(response)
      rescue Net::ReadTimeout, Net::OpenTimeout, Errno::ECONNREFUSED => e
        if retry_count < max_retries
          retry_count += 1
          sleep(2**retry_count) # Exponential backoff
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
        # Log error
        Rails.logger.error("Quikk API Error: #{response.code} - #{response.body}")
        JSON.parse(response.body) rescue { "error" => "Unknown error", "status" => response.code }
      end
    end
  end
end
