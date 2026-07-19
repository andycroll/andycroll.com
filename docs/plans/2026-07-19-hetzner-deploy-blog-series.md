# Blog series plan: Deploying a vanilla Rails app on Hetzner

Status: **planned** (drafting deferred). Companion to
`docs/runbooks/hatchbox-hetzner-new-app-setup.md`.

A "One Ruby Thing" series on andycroll.com. Each post = one idea, links its
[railstemplates.org](https://railstemplates.org) template where one exists, and back to the runbook.
Suggested cadence: weekly.

## Companion templates (railstemplates.org)

| Template | Status | URL |
|----------|--------|-----|
| lograge | shipped | `railstemplates.org/lograge/template` |
| appsignal | PR [#58](https://github.com/andycroll/railstemplates.org/pull/58) | `railstemplates.org/appsignal/template` |
| litestream | PR [#60](https://github.com/andycroll/railstemplates.org/pull/60) | `railstemplates.org/litestream/template` |
| structured-logging | PR [#59](https://github.com/andycroll/railstemplates.org/pull/59) | `railstemplates.org/structured-logging/template` |

## Posts (suggested order)

| # | Working title | The one idea | Runbook step | Links |
|---|---------------|--------------|--------------|-------|
| 1 | Bring-your-own-VPS: Rails on Hetzner with Hatchbox | Hetzner has no native Hatchbox integration — add it as a custom VPS; on a fresh app *nothing is inherited* | 0–2, 4 | runbook (no template) |
| 2 | Cloudflare in front of Hatchbox: the 525/522 dance | Proxied DNS, Let's Encrypt HTTP-01 via grey-cloud, then Full (strict) | 3 | runbook (no template) |
| 3 | The Litestream setting that saved my R2 bill | `sync-interval` is *both* latency and write-frequency; default `1s` → millions of Class A ops | 5 | litestream template |
| 4 | One JSON log line per request — and everything else | Raw STDOUT formatter + broadcast logger → journalctl & AppSignal Logs | 6 (logs) | lograge + structured-logging templates |
| 5 | AppSignal, wired through Rails credentials | Push key in encrypted credentials (no extra env), `HATCHBOX_RELEASE` for revisions | 6 (APM) | appsignal template; ties to `/ruby/use-rails-combined-credentials/` |
| 6 | (Capstone) A vanilla Rails app on Hetzner, end to end | The whole stack in one place; links every template | whole runbook | all templates |

## Notes for the writing phase

- Posts 3 and 5 have the strongest standalone hooks (a money gotcha; a clean credentials trick) —
  good candidates to lead with if not going strictly in deploy-order.
- Each template post carries the `rails app:template LOCATION=https://railstemplates.org/<name>/template`
  one-liner.
- Draft in the author's voice via **Spiral**, following house front matter
  (`category: ruby`, `layout: article`, `image:` block).
- Posts 3, 4, 5 should publish only once their railstemplates.org PRs merge so the template URLs are live.
