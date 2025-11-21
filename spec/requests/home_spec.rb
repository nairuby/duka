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

    it "includes the landing page content" do
      get root_path
      expect(response.body).to include("African Ruby")
      expect(response.body).to include("Community Store")
    end
  end
end
