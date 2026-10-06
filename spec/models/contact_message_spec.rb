# == Schema Information
#
# Table name: contact_messages
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  message    :text             not null
#  name       :string           not null
#  status     :string           default("new"), not null
#  subject    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe ContactMessage, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      contact_message = ContactMessage.new(
        name: "Jane Doe",
        email: "jane@example.com",
        message: "Hello there"
      )
      expect(contact_message).to be_valid
    end

    it "is not valid without a name" do
      contact_message = ContactMessage.new(email: "jane@example.com", message: "Hello")
      expect(contact_message).not_to be_valid
    end

    it "is not valid without an email" do
      contact_message = ContactMessage.new(name: "Jane Doe", message: "Hello")
      expect(contact_message).not_to be_valid
    end

    it "is not valid with a malformed email" do
      contact_message = ContactMessage.new(name: "Jane Doe", email: "not-an-email", message: "Hello")
      expect(contact_message).not_to be_valid
    end

    it "is not valid without a message" do
      contact_message = ContactMessage.new(name: "Jane Doe", email: "jane@example.com")
      expect(contact_message).not_to be_valid
    end

    it "is valid without a subject" do
      contact_message = ContactMessage.new(name: "Jane Doe", email: "jane@example.com", message: "Hello")
      expect(contact_message).to be_valid
    end

    it "defaults status to new" do
      contact_message = ContactMessage.create!(name: "Jane Doe", email: "jane@example.com", message: "Hello")
      expect(contact_message.status).to eq("new")
    end

    it "is not valid with an unknown status" do
      contact_message = ContactMessage.new(name: "Jane Doe", email: "jane@example.com", message: "Hello", status: "bogus")
      expect(contact_message).not_to be_valid
    end
  end
end
