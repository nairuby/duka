require 'rails_helper'

RSpec.describe "Health", type: :request do
  describe "GET /healthz/jobs" do
    it "returns 503 when solid_queue_processes has no recent heartbeat (or isn't provisioned in this env)" do
      get "/healthz/jobs"

      expect(response).to have_http_status(:service_unavailable)
      expect(JSON.parse(response.body)["status"]).to eq("down")
    end

    it "returns 200 when a worker heartbeated recently" do
      allow_any_instance_of(HealthController).to receive(:last_worker_heartbeat_at).and_return(30.seconds.ago)

      get "/healthz/jobs"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["status"]).to eq("ok")
    end
  end
end
