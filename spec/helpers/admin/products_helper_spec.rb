require 'rails_helper'

RSpec.describe Admin::ProductsHelper, type: :helper do
  # This helper doesn't have any methods yet, so just a basic test
  it "is included in the helper" do
    expect(helper.class.included_modules).to include(Admin::ProductsHelper)
  end
end
