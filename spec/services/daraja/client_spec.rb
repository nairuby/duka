# frozen_string_literal: true

require "rails_helper"

RSpec.describe Daraja::Client do
  let(:client) { described_class.new }

  describe "initialization and configuration" do
    it "determines transaction type and party_b based on till_no presence" do
      allow(Rails.application.credentials).to receive(:dig).with(:daraja).and_return({
        shortcode: "174379",
        till_no: "4362425",
        passkey: "passkey123"
      })

      c = described_class.new
      expect(c.send(:transaction_type)).to eq("CustomerBuyGoodsOnline")
      expect(c.send(:party_b)).to eq("4362425")
    end

    it "defaults to CustomerPayBillOnline when till_no is not provided" do
      allow(Rails.application.credentials).to receive(:dig).with(:daraja).and_return({
        shortcode: "174379",
        till_no: nil,
        passkey: "passkey123"
      })

      c = described_class.new
      expect(c.send(:transaction_type)).to eq("CustomerPayBillOnline")
      expect(c.send(:party_b)).to eq("174379")
    end

    it "generates base64 encoded password using shortcode, passkey, and timestamp" do
      allow(Rails.application.credentials).to receive(:dig).with(:daraja).and_return({
        shortcode: "174379",
        passkey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
      })

      c = described_class.new
      timestamp = "20261119120000"
      expected = Base64.strict_encode64("174379bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c91920261119120000")
      expect(c.send(:password, timestamp)).to eq(expected)
    end
  end

  describe "#stk_push" do
    it "returns error result when access token cannot be obtained" do
      allow(client).to receive(:access_token).and_return(nil)

      result = client.stk_push(
        amount: 1000,
        phone_number: "0712345678",
        reference: "ORD-123",
        description: "ARC Merch"
      )

      expect(result["ResponseCode"]).to eq("Error")
      expect(result["errorMessage"]).to include("Failed to obtain Daraja access token")
    end

    it "sends STK push request successfully when token is valid" do
      allow(client).to receive(:access_token).and_return("mock_token_123")
      fake_response = double(
        "Response",
        status: 200,
        body: { "ResponseCode" => "0", "CheckoutRequestID" => "ws_CO_123", "CustomerMessage" => "Success" }.to_json,
        success?: true
      )
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(fake_response)

      result = client.stk_push(
        amount: 1500,
        phone_number: "+254712345678",
        reference: "ORD-456",
        description: "Order 456"
      )

      expect(result["ResponseCode"]).to eq("0")
      expect(result["CheckoutRequestID"]).to eq("ws_CO_123")
    end

    it "handles empty response from Daraja" do
      allow(client).to receive(:access_token).and_return("mock_token_123")
      fake_response = double("Response", status: 500, body: "", success?: false)
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(fake_response)

      result = client.stk_push(amount: 100, phone_number: "0712345678", reference: "R", description: "D")
      expect(result["ResponseCode"]).to eq("Error")
      expect(result["errorMessage"]).to include("Empty response")
    end

    it "handles JSON parsing errors from Daraja" do
      allow(client).to receive(:access_token).and_return("mock_token_123")
      fake_response = double("Response", status: 502, body: "<html>Bad Gateway</html>", success?: false)
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(fake_response)

      result = client.stk_push(amount: 100, phone_number: "0712345678", reference: "R", description: "D")
      expect(result["ResponseCode"]).to eq("Error")
      expect(result["errorMessage"]).to include("Invalid response")
    end
  end

  describe "#stk_query" do
    it "returns error result when access token cannot be obtained" do
      allow(client).to receive(:access_token).and_return(nil)
      result = client.stk_query("ws_CO_999")
      expect(result["ResponseCode"]).to eq("Error")
      expect(result["errorMessage"]).to include("Failed to obtain Daraja access token")
    end

    it "queries payment status successfully when token is valid" do
      allow(client).to receive(:access_token).and_return("mock_token_123")
      fake_response = double(
        "Response",
        status: 200,
        body: { "ResponseCode" => "0", "ResultCode" => "0", "ResultDesc" => "The service request is processed successfully." }.to_json,
        success?: true
      )
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(fake_response)

      result = client.stk_query("ws_CO_999")
      expect(result["ResponseCode"]).to eq("0")
      expect(result["ResultCode"]).to eq("0")
    end
  end

  describe "#fetch_access_token" do
    it "fetches and returns the access token on successful authentication" do
      fake_response = double("Response", status: 200, body: { "access_token" => "abc123token" }.to_json, success?: true)
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(fake_response)

      token = client.send(:fetch_access_token)
      expect(token).to eq("abc123token")
    end

    it "returns nil when response body is empty" do
      fake_response = double("Response", status: 500, body: "", success?: false)
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(fake_response)

      expect(client.send(:fetch_access_token)).to be_nil
    end

    it "returns nil when authentication fails" do
      fake_response = double("Response", status: 400, body: { "errorMessage" => "Invalid credentials" }.to_json, success?: false)
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(fake_response)

      expect(client.send(:fetch_access_token)).to be_nil
    end
  end
end
