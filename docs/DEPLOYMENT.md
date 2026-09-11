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
**systemd `--user` service**.

### Symptom when it is not running

Checkout enqueues `Mpesa::ChargeJob` and redirects to the polling screen, but the
order never leaves `payment_status: "started"` and the STK prompt never reaches
the phone. `log/production.log` shows `[ActiveJob] Enqueued Mpesa::ChargeJob …`
with no matching `Performing` line.

### One-time setup (on the app server, as the deploy user)

```bash
mkdir -p ~/.config/systemd/user
cp /var/www/shop_rubycommunity_africa/current/deploy/solid_queue.service ~/.config/systemd/user/
loginctl enable-linger "$USER"          # keep the service alive without a login session
systemctl --user daemon-reload
systemctl --user enable --now solid_queue
```

Verify:

```bash
systemctl --user status solid_queue
journalctl --user -u solid_queue -f
```

The queue/cache/cable databases must exist and be migrated:

```bash
cd /var/www/shop_rubycommunity_africa/current
RAILS_ENV=production bin/rails db:prepare
```

### On every deploy

`config/deploy.rb` runs `deploy:restart_solid_queue` (`systemctl --user restart
solid_queue`) after `deploy:restart`, so the worker always picks up the new
release.
