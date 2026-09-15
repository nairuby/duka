class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  # GET /healthz/jobs — 200 if a Solid Queue worker has heartbeated recently,
  # 503 otherwise. The worker can silently stop (deploy didn't restart it,
  # crash-looped, box rebooted) while the web app itself stays perfectly
  # healthy on /up, which is exactly how M-Pesa charges went unnoticed for
  # days in production. Point an external uptime monitor at this endpoint.
  def jobs
    last_heartbeat = last_worker_heartbeat_at

    if last_heartbeat && last_heartbeat > 2.minutes.ago
      render json: { status: "ok", last_heartbeat_at: last_heartbeat }, status: :ok
    else
      render json: { status: "down", last_heartbeat_at: last_heartbeat }, status: :service_unavailable
    end
  end

  private

  def last_worker_heartbeat_at
    SolidQueue::Process.maximum(:last_heartbeat_at)
  rescue ActiveRecord::StatementInvalid
    # solid_queue_processes isn't provisioned in every environment (e.g. test,
    # or dev without the :solid_queue queue adapter) — report "down" instead
    # of a 500.
    nil
  end
end
