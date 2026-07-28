# Guide: Set up a new Rails app on Hatchbox + Hetzner (step by step)

A concrete, paste-into-a-terminal guide for standing up a vanilla Rails + SQLite app on a Hetzner
server managed by Hatchbox, with Litestream backups to object storage and Cloudflare in front for
DNS + TLS. Nothing is inherited on a fresh app, so this guide is mostly "don't forget X," in order.

Conventions used below:
- Hatchbox runs each app's processes as **user systemd** units owned by `deploy`
  (`systemctl --user …`, **no sudo**). Units are named `<app>-server` (puma) and
  `<app>-solid_queue` (worker).
- App lives at `/home/deploy/<app>/{current,releases,shared}`. Persistent data (SQLite DBs +
  Active Storage blobs) is under `shared/storage/`, symlinked into each release.
- Non-interactive `ssh host 'cmd'` may not load the deploy user's Ruby; the reliable pattern is
  to **`ssh` in interactively, then paste the block** — that's how the blocks below are framed.

Set these once locally:

```sh
export APP=myapp                          # your Hatchbox app name
export SRV=deploy@HETZNER_IP              # the Hetzner server
```

---

## 0. Prerequisites (once per server)

- [ ] Hetzner Cloud server provisioned and **connected to Hatchbox** (Hetzner has no native
      Hatchbox integration → add it as a **custom/bring-your-own VPS** over SSH).
- [ ] You can `ssh "$SRV"` as `deploy`.
- [ ] The repo is reachable by Hatchbox (deploy key added).
- [ ] Cloudflare zone for the domain, and you can edit its DNS + SSL settings.
- [ ] The app's `RAILS_MASTER_KEY` (from `config/credentials/production.key` or your secrets store).
- [ ] An object-storage bucket + keys for Litestream backups (e.g. Cloudflare R2).
- [ ] An AppSignal account + the app's **push API key**, if you want monitoring + logs.

---

## 1. Create the app in Hatchbox

Dashboard → the Hetzner server → **Add App**:
- Repo + branch (the branch Hatchbox auto-deploys from — usually `main`).
- Framework: Rails.

This creates the systemd units and `/home/deploy/<app>/` on first deploy — but **set env first**
(step 2), or the first deploy fails to boot.

---

## 2. Environment variables — set the WHOLE set, don't cherry-pick

> This is where fresh apps break. Nothing is inherited. A missing `RAILS_MASTER_KEY` is a loud
> boot error; a missing toggle (backups, worker) fails **silently**.

In Hatchbox → app → **Environment**, set:

```sh
RAILS_MASTER_KEY=...              # decrypts config/credentials/production.yml.enc
RAILS_ENV=production
SOLID_QUEUE_IN_PUMA=1             # run the Solid Queue worker inside puma (else a separate process)
LITESTREAM_IN_PUMA=1             # start Litestream from the puma plugin (see step 5)
# ...Litestream bucket + keys ONLY if litestream.yml reads them straight from ENV. If instead an
#    initializer maps Rails.application.credentials.litestream.* into config.litestream.* (the gem
#    then fills the $LITESTREAM_* placeholders at runtime), they're already covered by
#    RAILS_MASTER_KEY — no separate Litestream env vars needed. Check which pattern the app uses.
# ...plus every app-specific var (API keys, feature flags, etc.) — unless those also live in
#    encrypted credentials, in which case RAILS_MASTER_KEY covers them too.
```

---

## 3. Domain + SSL (Cloudflare)

Because the domain is Cloudflare-proxied, the public always resolves to Cloudflare — you point
the **origin** record at the server, and Cloudflare must be able to TLS-handshake it or you get
**HTTP 525**. Order:

1. Hatchbox → app → **Domains** → add `example.com` (+ `www.example.com`). This provisions a
   **Let's Encrypt** cert via HTTP-01.
2. If the HTTP-01 challenge won't validate through the proxy, set the Cloudflare record to
   **DNS-only (grey cloud)** pointed at the Hetzner IP, let the cert issue, then re-proxy.
   (Alternatively keep it proxied and turn **"Always Use HTTPS" off** during issuance.)
3. Verify the origin cert directly:
   ```sh
   echo | openssl s_client -connect HETZNER_IP:443 -servername example.com 2>/dev/null \
     | openssl x509 -noout -issuer -dates          # Let's Encrypt issuer, valid dates
   ```
4. Point the Cloudflare origin A record at the Hetzner IP; set SSL/TLS mode to **Full (strict)**.

> 525 = Cloudflare reached origin but TLS failed → cert missing/untrusted (steps 1–3).
> 522 = origin unreachable → app/port 443 not up.

---

## 4. Deploy

A vanilla app needs **no custom deploy commands** — Hatchbox precompiles assets and, with the
**"Run migrations"** toggle on, migrates on each deploy. Trigger the deploy in Hatchbox and watch
the log; the classic first-deploy failure is a boot error mentioning credentials → step 2
(`RAILS_MASTER_KEY` missing or wrong).

---

## 5. Litestream backups (SQLite → object storage)

Litestream replication must be **started** by something — it isn't automatic. The simplest pattern
for a single server is the **Puma plugin**: `config/puma.rb` has
`plugin :litestream if ENV["LITESTREAM_IN_PUMA"]`, enabled by `LITESTREAM_IN_PUMA=1` (step 2). Puma
forks and supervises `litestream replicate` as a **mutual watchdog** — if Litestream dies it stops
Puma, so a dead backup surfaces as a visible outage instead of silent data loss.

Confirm the replica bucket/endpoint/keys resolve so the watchdog doesn't crash-loop Puma:

```sh
ssh "$SRV"; cd /home/deploy/$APP/current
# A login/non-interactive shell does NOT load the systemd EnvironmentFile, so source the app env
# first — otherwise RAILS_MASTER_KEY is unset and (credentials-sourced) Litestream vars read blank:
set -a; . /home/deploy/$APP/.hatchbox.env; set +a
# `litestream:env` resolves the vars from whichever source the app uses (ENV or credentials) — but
# it prints the SECRET access key, so redact before pasting anywhere shared:
RAILS_ENV=production bin/rails litestream:env 2>/dev/null | sed -E 's/((KEY|SECRET)[A-Z_]*=).*/\1<redacted>/'
```

> **Single-writer rule:** exactly one process may replicate to a given bucket path. One
> `litestream replicate` per web server — if you scale web horizontally, switch to a single
> dedicated Litestream process instead of the Puma plugin.

**Raise `sync-interval` — the default (`1s`) is expensive.** In `config/litestream.yml` each replica
inherits Litestream's default `sync-interval: 1s`, which is *both* your replication latency (the
window of writes you lose if the box dies before a sync) *and* how often Litestream writes to the
bucket. At `1s` a busy DB racks up **millions of Class A operations/month** — one engineer left it at
the default and ran up ~20M ops (nearing $100) on R2. Set it to `10s`–`1m`: you trade a few seconds /
a minute of potential data loss for ~10–60× fewer, cheaper writes.

```yaml
# config/litestream.yml
dbs:
  - path: storage/production.sqlite3
    replicas:
      - type: s3
        bucket: $LITESTREAM_REPLICA_BUCKET
        # ...bucket/endpoint/keys...
        sync-interval: 10s     # default 1s — this is latency AND write frequency
```

See the post-mortem: <https://notes.ghinda.com/post/remember-to-the-frequency-for-replication-to-litestream>

---

## 6. Monitoring + JSON logs (AppSignal)

App-repo work — commit it **before** the step 4 deploy so the first release reports. Canonical
reference implementation: the **usingrails** repo. The request-line piece is templated at
railstemplates.org (`rails app:template LOCATION=https://railstemplates.org/lograge/template`);
AppSignal and the broadcast logger below are not in that template yet — copy them from usingrails.

**AppSignal (APM + errors + logs).** `gem "appsignal"`, then `bundle exec appsignal install`
(writes `config/appsignal.rb`):

```ruby
# config/appsignal.rb
Appsignal.configure do |config|
  config.activate_if_environment("production")
  config.name = "MyApp"
  config.revision = ENV["HATCHBOX_RELEASE"] if ENV["HATCHBOX_RELEASE"]   # ties samples to the deploy
  config.push_api_key = Rails.application.credentials.appsignal_push_api_key
  config.filter_parameters = %w[password token secret api_key ...]       # exact-string match, no regex
end
```

- **Key via credentials.** `bin/rails credentials:edit --environment production` → add
  `appsignal_push_api_key: …`. `RAILS_MASTER_KEY` (step 2) already decrypts it in production, so
  **no extra Hatchbox env var is needed**. (Or set `APPSIGNAL_PUSH_API_KEY` in Hatchbox env to
  override — `Rails.app.creds` / AppSignal check ENV first.)
- **`HATCHBOX_RELEASE`** is injected by Hatchbox on every deploy → AppSignal ties errors and
  samples back to a specific release. Nothing to set.

**JSON logs (STDOUT → journalctl + AppSignal Logs).** Under Hatchbox, Puma logs to STDOUT →
journalctl. Emit **one bare JSON object per line** so both journalctl and AppSignal Logs parse
typed fields. Compose the logger in `config/environments/production.rb`:

```ruby
log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
raw = ->(_severity, _time, _progname, msg) { "#{msg}\n" }     # drop the "I, [ts #pid] INFO -- :" prefix
stdout = Logger.new($stdout, level: log_level).tap { |l| l.formatter = raw }
appsignal = Appsignal::Logger.new("rails")
appsignal.broadcast_to(stdout)                                # NOT ActiveSupport::BroadcastLogger
config.logger = ActiveSupport::TaggedLogging.new(appsignal)
config.log_level = log_level
config.solid_queue.silence_polling = log_level != "debug"

config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new
config.lograge.ignore_actions = %w[Rails::HealthController#show]   # /up spam burns AppSignal Logs quota
config.lograge.custom_payload { |c| {request_id: c.request.request_id}.compact }
config.lograge.logger = config.logger
```

For per-job / external-API / `Rails.event` / exception JSON lines, copy
`config/initializers/structured_logging.rb` from usingrails.

Non-obvious bits (each fails **silently**):
- **Raw STDOUT formatter** — without it every line keeps the `I, [ts] INFO -- :` prefix and stops
  being valid JSON.
- **`Appsignal::Logger#broadcast_to`, not `ActiveSupport::BroadcastLogger`** — the latter conflicts
  with `TaggedLogging` when one leg is an AppSignal logger.
- **Explicit STDOUT logger `level:`** — `config.log_level` only filters the AppSignal leg; without
  it the STDOUT leg defaults to `:debug` and SolidQueue polling floods journalctl.
- **`ignore_actions` the healthcheck** — Cloudflare + uptime monitors hammer `/up`;
  `config.silence_healthcheck_path` doesn't work through the broadcast logger.

---

## 7. Verify (paste this whole block on the server)

```sh
ssh "$SRV"
```
```sh
cd /home/deploy/$APP/current
# source the app env — a login shell does NOT load the systemd EnvironmentFile, so without this
# RAILS_MASTER_KEY is unset and every credentials-backed check below silently reads blank:
set -a; . /home/deploy/$APP/.hatchbox.env; set +a

# services up?
systemctl --user list-units "$APP-*"
systemctl --user is-active "$APP-server" "$APP-solid_queue"

# credentials actually decrypt (RAILS_MASTER_KEY correct) — not just "Rails boots":
RAILS_ENV=production bin/rails runner 'puts "boot OK; credentials_decrypt=#{Rails.application.credentials.config.present?}"'

# app serves locally (find its port from the unit or ps):
PORT=$(ps -eo cmd | grep -oP "$APP.*tcp://127.0.0.1:\K[0-9]+" | head -1); echo "port=$PORT"
curl -sI "http://127.0.0.1:$PORT/" | head -1

# backups: replicate process is a CHILD of puma, fresh generation lands:
ps -eo pid,ppid,cmd | grep -iE "puma|litestream replicate" | grep -v grep
RAILS_ENV=production bin/rails litestream:generations -- -database=storage/production.sqlite3

# monitoring: AppSignal agent healthy + push key resolved:
RAILS_ENV=production bundle exec appsignal diagnose 2>&1 | grep -iE "push api key|agent|started" | head

# JSON logs: recent lines are bare JSON objects (no I,[ts] prefix), /up absent:
journalctl --user -u "$APP-server" -n 50 --no-pager | grep -E '^\{' | tail -3
```

Then, from anywhere:

```sh
curl -sI https://example.com/ | head -1          # 200 via Cloudflare → Hetzner origin
```

---

## Gotcha checklist (the fresh-app failure modes, in the order they bite)

1. **Missing `RAILS_MASTER_KEY`** → credentials don't decrypt → boot/verify errors.
2. **Missing `LITESTREAM_IN_PUMA` / `SOLID_QUEUE_IN_PUMA`** → silent behaviour change (no backup /
   worker not running). Set the whole env, not just the vars you remember.
3. **Assuming unit names/ports** → they differ per app and per box. `systemctl --user list-units`
   + the SSH login banner are ground truth.
4. **Cert after DNS flip** → 525. Add domain + issue cert (grey-cloud for HTTP-01) *before*
   pointing the Cloudflare origin at the server. The cert is issued by the box's ACME responder,
   **independent of the app's Puma** — so you can get it even with the web unit stopped (handy when
   migrating an app whose Puma you're deliberately keeping down until cutover).
5. **Watchdog crash-loop** → Litestream-in-Puma with an unreachable bucket takes Puma down. Make
   the bucket resolve first, or unset the toggle while you fix it.
6. **AppSignal silently no-ops** → a missing/unreadable push key means no data and no error.
   `appsignal diagnose` (or the dashboard) is ground truth, not the deploy log.
7. **Log lines aren't valid JSON** → the default formatter or `ActiveSupport::BroadcastLogger` left
   a severity prefix / duplicate lines, so AppSignal Logs can't type the fields. Raw formatter +
   `Appsignal::Logger#broadcast_to`.
