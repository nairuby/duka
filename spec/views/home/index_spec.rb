# frozen_string_literal: true

require "rails_helper"

RSpec.describe "home/index", type: :view do
  it "renders the landing page partial" do
    render

    expect(rendered).to match(/African Ruby/)
    expect(rendered).to match(/Community Store/)
  end

  it "includes all landing page sections" do
    render

    # Check for navbar
    expect(rendered).to have_css("nav")

    # Check for hero section
    expect(rendered).to match(/Wear Your/)

    # Check for products section
    expect(rendered).to match(/All Products/)

    # Check for footer
    expect(rendered).to have_css("footer")
  end
end
