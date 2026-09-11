# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :user, "ubuntu"
set :application, "duka"
set :repo_url, "git@github.com:nairuby/duka.git"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/shop_rubycommunity_africa"

# Default value for :linked_files is []
set :linked_files, %w[config/database.yml config/credentials/production.key]

# Default value for linked_dirs is []
set :linked_dirs, %w[vendor/bundle public/system log tmp/pids tmp/cache tmp/sockets public/packs .bundle node_modules storage]

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join("tmp/restart.txt")
    end
  end

  # Production runs Active Job on Solid Queue (config/environments/production.rb),
  # which needs a long-running supervisor (`bin/jobs`). Under Passenger there is
  # no in-process option, so it runs as a systemd --user service. Without this
  # restart, enqueued jobs (M-Pesa charge, order mailers) never run after a deploy.
  # One-time server setup: see docs/DEPLOYMENT.md.
  desc "Restart Solid Queue"
  task :restart_solid_queue do
    on roles(:app) do
      execute :systemctl, "--user", "restart", "solid_queue"
    end
  end

  after :finishing, "deploy:cleanup"
  after :finishing, "deploy:restart"
  after :finishing, "deploy:restart_solid_queue"
end
