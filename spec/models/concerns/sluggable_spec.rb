# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sluggable do
  let(:test_class) do
    Class.new(ApplicationRecord) do
      self.table_name = "products"
      include Sluggable
      friendly_slug_scope to_slug: :name
    end
  end

  it "extends FriendlyId when included" do
    expect(test_class.singleton_class.included_modules).to include(FriendlyId::Base)
  end

  it "configures friendly_id slug base correctly" do
    expect(test_class.friendly_id_config.base).to eq(:name)
  end

  it "supports custom use options" do
    custom_class = Class.new(ApplicationRecord) do
      self.table_name = "products"
      include Sluggable
      friendly_slug_scope to_slug: :name, use: [ :slugged, :finders ]
    end

    expect(custom_class.friendly_id_config.uses?(:slugged)).to be(true)
    expect(custom_class.friendly_id_config.uses?(:finders)).to be(true)
  end
end
