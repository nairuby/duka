# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "renders successfully" do
      get root_path
      expect(response).to be_successful
    end

    it "includes the default Open Graph tags" do
      get root_path
      expect(response.body).to include(%(property="og:title" content="ARC Duka"))
      expect(response.body).to include(%(property="og:image"))
    end
  end
end
