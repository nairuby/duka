# Deployment

Production (`https://shop.rubycommunity.africa`) is deployed with **Capistrano 3 + Passenger + nginx** on a DigitalOcean droplet.

```bash
cap production deploy
```

Config: `config/deploy.rb`, `config/deploy/production.rb`. Required env var: `DEPLOY_SERVER_IP`.

## Background jobs (Solid Queue) — required for M-Pesa

In production, Active Job uses the `:solid_queue` adapter with a dedicated
`duka_production_queue` database (`config/environments/production.rb`,
`config/database.yml`). Jobs enqueued by the app — the **M-Pesa STK charge**
(`Mpesa::ChargeJob`), `Mpesa::VerifyPaymentJob`, and the order confirmation
mailer — only run if a Solid Queue supervisor process is running.

Passenger has no in-process job runner (the `SOLID_QUEUE_IN_PUMA` option in
`config/puma.rb` does not apply), so the supervisor (`bin/jobs`) runs as a
**system-level systemd service** (`deploy/solid_queue.service`), running as
the `ubuntu` user.

### Symptom when it is not running

Checkout enqueues `Mpesa::ChargeJob` and redirects to the polling screen, but the
order never leaves `payment_status: "started"` and the STK prompt never reaches
the phone. `log/production.log` shows `[ActiveJob] Enqueued Mpesa::ChargeJob …`
with no matching `Performing` line. Confirm with:

```bash
sudo -iu ubuntu
cd /var/www/shop_rubycommunity_africa/current
RAILS_ENV=production bin/rails runner 'pp SolidQueue::Process.all.map { |p| [p.kind, p.last_heartbeat_at] }'
```

An empty result (or heartbeats far in the past) means no worker is running.

### One-time setup (on the app server, as root/sudo)

**Run all `bin/rails` / `bin/jobs` / `bundle` commands as the `ubuntu` user** —
it has the asdf-managed Ruby 3.4.7 the app needs. Running them as `root` picks
up the system Ruby (2.7 on this box) and fails with a `Bundler::GemfileError`
about the `windows` platform.

```bash
cp /var/www/shop_rubycommunity_africa/current/deploy/solid_queue.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now solid_queue
systemctl status solid_queue --no-pager
```

The queue/cache/cable databases must exist and be migrated (as `ubuntu`):

```bash
cd /var/www/shop_rubycommunity_africa/current
RAILS_ENV=production bin/rails db:prepare
```

Allow the deploy user (`ubuntu`) to restart the service without a password —
Capistrano runs this non-interactively:

```bash
echo 'ubuntu ALL=(root) NOPASSWD: /bin/systemctl restart solid_queue' | sudo tee /etc/sudoers.d/solid-queue
```

### On every deploy

`config/deploy.rb` runs `deploy:restart_solid_queue` (`sudo systemctl restart
solid_queue`) after `deploy:restart`, so the worker always picks up the new
release. If the sudoers entry above isn't in place, this step will fail —
restart it manually after a deploy in the meantime:
`sudo systemctl restart solid_queue`.

### Debugging

```bash
sudo journalctl -u solid_queue -f
sudo systemctl status solid_queue --no-pager
```

A crash loop that logs a `Bundler::GemfileError` mentioning `windows` means the
unit is running the wrong Ruby — check `ExecStart`/`PATH` in
`deploy/solid_queue.service` point at the asdf shims, not system Ruby.
