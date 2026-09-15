# Usage: bin/rails runner script/test_brevo.rb <recipient_email>

recipient = ARGV[0]

if recipient.blank?
  puts "Please provide a recipient email address."
  puts "Usage: bin/rails runner script/test_brevo.rb your-email@example.com"
  exit 1
end

puts "Attempting to send a test email to #{recipient} via Brevo..."

begin
  # Create a simple mailer on the fly for testing
  mail = ActionMailer::Base.mail(
    from: Rails.application.credentials.dig(:brevo, :user_name) || "test@example.com",
    to: recipient,
    subject: "Brevo Connection Test - #{Time.now}",
    body: "If you received this email, your Brevo SMTP configuration is working correctly!"
  )

  # Enable raising errors for this specific delivery
  mail.delivery_method.settings = Rails.application.config.action_mailer.smtp_settings

  puts "SMTP Settings:"
  puts "  Address: #{mail.delivery_method.settings[:address]}"
  puts "  User Name: #{mail.delivery_method.settings[:user_name]}"
  puts "  Port: #{mail.delivery_method.settings[:port]}"

  mail.deliver_now
  puts "Success! The test email has been sent."
  puts "Check your inbox at #{recipient} and also check the Brevo dashboard logs."
rescue => e
  puts "Failed to send email!"
  puts "Error: #{e.class} - #{e.message}"
  puts "\nFull Backtrace:"
  puts e.backtrace.first(10).join("\n")

  if e.message.include?("Authentication failed")
    puts "\nTIP: Check your Brevo API key and user_name in your credentials."
  elsif e.message.include?("Connection refused")
    puts "\nTIP: Check if your network allows outgoing connections on port 587."
  end
end
