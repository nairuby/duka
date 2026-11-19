# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Avo Custom Resource Controllers", type: :controller do
  describe Avo::ContactMessagesController do
    it "inherits from Avo::ResourcesController" do
      expect(described_class.superclass).to eq(Avo::ResourcesController)
      expect(described_class.new).to be_a(Avo::ResourcesController)
    end
  end

  describe Avo::OrderItemsController do
    it "inherits from Avo::ResourcesController" do
      expect(described_class.superclass).to eq(Avo::ResourcesController)
      expect(described_class.new).to be_a(Avo::ResourcesController)
    end
  end

  describe Avo::OrdersController do
    it "inherits from Avo::ResourcesController" do
      expect(described_class.superclass).to eq(Avo::ResourcesController)
      expect(described_class.new).to be_a(Avo::ResourcesController)
    end
  end

  describe Avo::PaymentTransactionsController do
    it "inherits from Avo::ResourcesController" do
      expect(described_class.superclass).to eq(Avo::ResourcesController)
      expect(described_class.new).to be_a(Avo::ResourcesController)
    end
  end

  describe Avo::ProductsController do
    it "inherits from Avo::ResourcesController" do
      expect(described_class.superclass).to eq(Avo::ResourcesController)
      expect(described_class.new).to be_a(Avo::ResourcesController)
    end
  end

  describe Avo::UsersController do
    it "inherits from Avo::ResourcesController" do
      expect(described_class.superclass).to eq(Avo::ResourcesController)
      expect(described_class.new).to be_a(Avo::ResourcesController)
    end
  end

  describe Avo::VariantsController do
    it "inherits from Avo::ResourcesController" do
      expect(described_class.superclass).to eq(Avo::ResourcesController)
      expect(described_class.new).to be_a(Avo::ResourcesController)
    end
  end
end
