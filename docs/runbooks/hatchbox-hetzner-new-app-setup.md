# Guide: Set up a new Rails app on Hatchbox + Hetzner (step by step)

A concrete, paste-into-a-terminal guide for standing up a Rails + SQLite + Litestream + Solid
Queue app on a Hetzner server managed by Hatchbox, fronted by Cloudflare. Written from a real
migration where every failure was **the fresh app not inheriting a setting** — so this guide is
mostly "don't forget X," in order.

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
export REF=deploy@REFERENCE_APP_IP        # an existing app to copy env/commands from (optional)
```

---

## 0. Prerequisites (once per server)

- [ ] Hetzner Cloud server provisioned and **connected to Hatchbox** (Hetzner has no native
      Hatchbox integration → add it as a **custom/bring-your-own VPS** over SSH).
- [ ] You can `ssh "$SRV"` as `deploy`.
- [ ] The repo is reachable by Hatchbox (deploy key added).
- [ ] Cloudflare zone for the domain, and you can edit its DNS + SSL settings.
- [ ] The app's `RAILS_MASTER_KEY` (from `config/credentials/production.key` or your secrets store).

Confirm the box + Ruby toolchain:

```sh
ssh "$SRV"
```
```sh
uname -a; nproc; free -h; df -h /
ls -la /home/deploy/                       # existing apps share this box — note them
```

---

## 1. Create the app in Hatchbox

Dashboard → the Hetzner server → **Add App**:
- Repo + branch (the branch Hatchbox auto-deploys from — usually `main`).
- Framework: Rails.

This creates the systemd units and `/home/deploy/<app>/` on first deploy — but **do not deploy
yet**. Set env + deploy commands first (steps 2–3), or the first deploy fails.

---

## 2. Environment variables — copy the WHOLE set, don't cherry-pick

> This is where fresh apps break. Nothing is inherited. Missing vars fail **silently** (jemalloc
> = quiet perf change) or **loudly** (no `RAILS_MASTER_KEY` = boot error).

In Hatchbox → app → **Environment**, set at minimum:

```sh
RAILS_MASTER_KEY=...              # decrypts config/credentials/production.yml.enc
RAILS_ENV=production
SOLID_QUEUE_IN_PUMA=1             # if the worker runs inside puma (else a separate process)
LITESTREAM_IN_PUMA=1             # if using the litestream Puma plugin (see step 6)
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2   # jemalloc — confirm the path on the box
# ...plus every app-specific var (API keys, feature flags, etc.)
```

If you're cloning an existing app, copy its entire env block, then **prove parity** without
printing secrets (compares variable *names* only):

```sh
diff \
  <(ssh "$REF" "cut -d= -f1 /home/deploy/REFERENCE_APP/current/.hatchbox.env | sort") \
  <(ssh "$SRV" "cut -d= -f1 /home/deploy/$APP/current/.hatchbox.env | sort")
# empty output = match; a '<' line is a var set on the reference app but missing on the new one
```

(Confirm the jemalloc path first: `ssh "$SRV" 'ls /usr/lib/*/libjemalloc.so.2'`.)

---

## 3. Deploy commands — order matters

Hatchbox → app → **Deploy commands**. If the app uses **sqlpkg** (SQLite extensions), it MUST
be first — `config/database.yml` calls `Sqlpkg.path_for(...)` at load time, so *any* rake/rails
task (assets, migrations) aborts with `Sqlpkg::ExtensionNotInstalledError` until the extension
is installed into that release's (gitignored) `.sqlpkg/`:

```
bundle exec sqlpkg install
bundle exec rails assets:precompile
```

(Migrations are usually a separate Hatchbox toggle — leave "Run migrations" on for Rails apps.)

Verify the app actually uses sqlpkg before adding it: `grep -rn Sqlpkg config/database.yml`.

---

## 4. Domain + SSL (Cloudflare)

Because the domain is Cloudflare-proxied, the public always resolves to Cloudflare — you point
the **origin** record at the server, and Cloudflare must be able to TLS-handshake it or you get
**HTTP 525**. Order:

1. Hatchbox → app → **Domains** → add `example.com` (+ `www.example.com`). This provisions a
   **Let's Encrypt** cert via HTTP-01.
2. If the HTTP-01 challenge won't validate through the proxy, set the Cloudflare record to
   **DNS-only (grey cloud)** pointed at the Hetzner IP, let the cert issue, then re-proxy.
   (Alternatively keep it proxied and turn **"Always Use HTTPS" off** during issuance.)
3. **Wildcard domains** (`*.example.com`) can't use HTTP-01 — they need **DNS-01**, so Hatchbox
   asks for a DNS API token. For Cloudflare, create a token (My Profile → API Tokens) with
   **Zone → DNS → Edit** + **Zone → Zone → Read**, scoped to the one zone. Avoid wildcards if you
   only serve a couple of hostnames — explicit domains need no token.
4. Verify the origin cert directly:
   ```sh
   echo | openssl s_client -connect HETZNER_IP:443 -servername example.com 2>/dev/null \
     | openssl x509 -noout -issuer -dates          # Let's Encrypt issuer, valid dates
   ```
5. Point the Cloudflare origin A record at the Hetzner IP; set SSL/TLS mode to **Full (strict)**.

> 525 = Cloudflare reached origin but TLS failed → cert missing/untrusted (steps 1–4).
> 522 = origin unreachable → app/port 443 not up.

---

## 5. Deploy

Trigger the deploy in Hatchbox. Watch the log for the two classic first-deploy failures:
- `Sqlpkg::ExtensionNotInstalledError` → step 3 (sqlpkg deploy command missing/misordered).
- Boot errors mentioning credentials → step 2 (`RAILS_MASTER_KEY` missing).

If `sqlpkg install` fails, the server can't reach the extension's GitHub release — check
outbound egress.

---

## 6. Litestream backups (SQLite → object storage)

If the app replicates SQLite with Litestream, replication must be **started** by something — it
isn't automatic. Two patterns:

- **Puma plugin (recommended, single-server):** `config/puma.rb` has
  `plugin :litestream if ENV["LITESTREAM_IN_PUMA"]`, enabled by setting `LITESTREAM_IN_PUMA=1`
  (step 2). Puma forks + supervises `litestream replicate`; it's a **mutual watchdog** (if
  Litestream dies it stops Puma, surfacing a dead backup as a visible outage). In the repo →
  every server gets it automatically.
- **Standalone Hatchbox process:** add a background process running `bin/rails litestream:replicate`
  → comes up as `<app>-litestream.service`. Isolated from web (a bad backup won't take the site
  down), but it's per-app dashboard config you must remember on every app.

**Single-writer rule:** exactly one process may replicate to a given bucket path. Never run two
(e.g. old + new server during a migration). One `litestream replicate` per web server — if you
scale web horizontally, switch to a single dedicated process.

Confirm the replica bucket/endpoint/keys resolve **before** enabling a watchdog plugin, or a
misconfigured bucket crash-loops Puma:

```sh
ssh "$SRV"; cd /home/deploy/$APP/current
RAILS_ENV=production bin/rails litestream:env    # bucket + endpoint + key id all populated
```

---

## 7. Verify (paste this whole block on the server)

```sh
ssh "$SRV"
```
```sh
cd /home/deploy/$APP/current

# services up?
systemctl --user list-units "$APP-*"
systemctl --user is-active "$APP-server" "$APP-solid_queue"

# credentials decrypt (RAILS_MASTER_KEY correct) + sqlpkg resolves (if used):
RAILS_ENV=production bin/rails runner 'puts "boot OK"'
RAILS_ENV=production bin/rails runner 'puts(defined?(Sqlpkg) ? "sqlpkg loaded" : "no sqlpkg")'

# app serves locally (find its port from the unit or ps):
PORT=$(ps -eo cmd | grep -oP "$APP.*tcp://127.0.0.1:\K[0-9]+" | head -1); echo "port=$PORT"
curl -sI "http://127.0.0.1:$PORT/" | head -1

# backups (if using Litestream): replicate process is a CHILD of puma, fresh generation lands:
ps -eo pid,ppid,cmd | grep -iE "puma|litestream replicate" | grep -v grep
RAILS_ENV=production bin/rails litestream:generations -- -database=storage/production.sqlite3
```

Then, from anywhere:

```sh
curl -sI https://example.com/ | head -1          # 200 via Cloudflare → Hetzner origin
```

---

## Gotcha checklist (the fresh-app failure modes, in the order they bite)

1. **Empty Deploy commands** → sqlpkg not installed → `database.yml` aborts. Add `bundle exec
   sqlpkg install` **first**.
2. **Missing `RAILS_MASTER_KEY`** → credentials don't decrypt → boot/verify errors.
3. **Missing `LITESTREAM_IN_PUMA` / jemalloc / `SOLID_QUEUE_IN_PUMA`** → silent behaviour change
   (no backup / worse memory / worker not running). Copy the whole env; verify with the key-diff.
4. **Assuming unit names/ports** → they differ per app and per box. `systemctl --user list-units`
   + the SSH login banner are ground truth.
5. **Cert after DNS flip** → 525. Add domain + issue cert (grey-cloud for HTTP-01) *before*
   pointing the Cloudflare origin at the server.
6. **Running release predates a merged fix** → redeploy; an env toggle can't activate code that
   isn't in the deployed release.
7. **Watchdog crash-loop** → Litestream-in-Puma with an unreachable bucket takes Puma down. Make
   the bucket resolve first, or unset the toggle while you fix it.
8. **(Migrations only) rsyncing a live SQLite file** → `database disk image is malformed`. Stop
   the app, `PRAGMA wal_checkpoint(TRUNCATE)`, copy only `production.sqlite3`, and clear any stale
   `-wal`/`-shm` on the destination first.
