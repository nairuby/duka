require_relative 'config/environment'

quikk = Quikk::Client.new

puts "Testing Charge with tryapi.quikk.dev/v1/payments/charge (Headers only)"
begin
  response = quikk.charge(
    amount: 1,
    phone_number: "254700000000",
    reference: "TEST-#{Time.now.to_i}",
    description: "Test Charge"
  )
  puts "Response: #{response.inspect}"
rescue => e
  puts "Error: #{e.message}"
end
