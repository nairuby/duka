# frozen_string_literal: true

set :stage, :production
set :branch, "main"

server ENV.fetch("DEPLOY_SERVER_IP") { raise "DEPLOY_SERVER_IP environment variable is not set" }, user: "ubuntu", roles: %w[app db web]
