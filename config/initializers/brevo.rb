Brevo.configure do |config|
  config.api_key["api-key"] = Rails.application.credentials.dig(:brevo, :api_key)
end
