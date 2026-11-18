# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid email and password" do
      user = User.new(email: "dev@example.com", password: "password123", password_confirmation: "password123")
      expect(user).to be_valid
    end

    it "is invalid without an email" do
      user = User.new(password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is invalid with a duplicate email" do
      User.create!(email: "unique@example.com", password: "password123")
      duplicate = User.new(email: "unique@example.com", password: "password123")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it "is invalid with a short password" do
      user = User.new(email: "dev@example.com", password: "123")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe "roles" do
    it "defaults admin to false" do
      user = User.new(email: "user@example.com", password: "password123")
      expect(user.admin).to be(false)
      expect(user.admin?).to be(false)
    end

    it "can be assigned an admin role" do
      admin = User.new(email: "admin@example.com", password: "password123", admin: true)
      expect(admin.admin).to be(true)
      expect(admin.admin?).to be(true)
    end
  end

  describe "associations" do
    it "has many orders" do
      association = described_class.reflect_on_association(:orders)
      expect(association.macro).to eq(:has_many)
    end
  end
end
