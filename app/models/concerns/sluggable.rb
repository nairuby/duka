# frozen_string_literal: true
# Allow models to have slugs
module Sluggable
  extend ActiveSupport::Concern
  included do
    extend FriendlyId
  end
  class_methods do
    def friendly_slug_scope(to_slug:, use: :slugged)
      friendly_id to_slug, use: use
    end
  end
end
