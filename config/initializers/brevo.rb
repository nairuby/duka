if Rails.env.production?
  template_id = Rails.application.credentials.dig(:brevo, :order_confirmation_template_id)
  api_key     = Rails.application.credentials.dig(:brevo, :api_key)

  raise "Missing credential: brevo.api_key" if api_key.blank?
  raise "Missing credential: brevo.order_confirmation_template_id" if template_id.blank?
end
