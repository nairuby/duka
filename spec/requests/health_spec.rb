require 'rails_helper'

RSpec.describe "Health", type: :request do
  describe "GET /healthz/jobs" do
    it "returns 503 when no Solid Queue worker has heartbeated recently" do
      allow(SolidQueue::Process).to receive(:maximum).with(:last_heartbeat_at).and_return(10.minutes.ago)

      get "/healthz/jobs"

      expect(response).to have_http_status(:service_unavailable)
      expect(JSON.parse(response.body)["status"]).to eq("down")
    end

    it "returns 200 when a worker heartbeated recently" do
      allow(SolidQueue::Process).to receive(:maximum).with(:last_heartbeat_at).and_return(30.seconds.ago)

      get "/healthz/jobs"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["status"]).to eq("ok")
    end
  end
end
