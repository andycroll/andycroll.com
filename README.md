# andycroll.com

Personal website and blog for Andy Croll. Jekyll → Cloudflare Workers (static assets) → Cloudflare Image Transformations.

## Local development

```bash
bundle install
bundle exec jekyll serve            # http://localhost:4000
bundle exec jekyll serve --future   # include future-dated drafts
```

In development, images render from raw `/images/…` paths so `jekyll serve` resolves them locally. In production (`JEKYLL_ENV=production`), every raster `<img>` is routed through `_includes/cf_image.html` which emits `/cdn-cgi/image/format=auto,width=…/images/…`. The URL format is documented in [Transform via URL](https://developers.cloudflare.com/images/transform-images/transform-via-url/).

## Deployment

The site deploys to a Cloudflare Worker named **`andycroll-com`** via `wrangler.jsonc`. The `.github/workflows/deploy.yml` workflow is `workflow_dispatch`-only — trigger it from **Actions → Deploy → Run workflow → main**.

The job runs `bundle exec jekyll build` under `LANG=C.UTF-8` (Cloudflare's build container is otherwise ASCII-8BIT, which crashes Jekyll's URL unescape on non-ASCII filenames), then `cloudflare/wrangler-action@v3 deploy` with wrangler v4 pinned (static-assets-only Workers require v4).

Smoke-test on the Worker's `*.workers.dev` URL before pointing DNS at it. Note: `/cdn-cgi/image/…` URLs return 404 on `*.workers.dev` because Image Transformations only runs on customer zones — that part can only be verified after DNS cutover (see below).

## Where things live

- `_posts/YYYY/` — blog posts (front matter drives the layout, hero image, OG card)
- `_layouts/` — `default.html` + `article.html`
- `_includes/` — reusable partials including `cf_image.html` (the production image helper)
- `images/` — raster sources; ship in `_site/images/`
- `assets/css/app.css` — Tailwind 4 entry point
- `wrangler.jsonc` — Worker config: `name`, `compatibility_date`, `assets.directory: "_site"`

## First-time setup

One-time tasks to run before the deploy workflow can be triggered.

### Cloudflare

1. **Add the zone to Cloudflare**: `andycroll.com` must be on Cloudflare DNS. Records that serve site traffic should be proxied (orange-clouded) so requests go through Cloudflare's edge.
2. **Enable Image Transformations**: dashboard → **Images → Transformations** → select the `andycroll.com` zone → enable transformations. Without this, `/cdn-cgi/image/…` URLs return 404. Pricing is usage-based: **5,000 unique transformations per month free**, then **$0.50 per additional 1,000** ([pricing docs](https://developers.cloudflare.com/images/pricing/)).
3. **API token**: follow Cloudflare's [GitHub Actions guide](https://developers.cloudflare.com/workers/ci-cd/external-cicd/github-actions/) to create a token. The token needs write access to Workers Scripts on the account that owns the `andycroll-com` Worker. Scope account resources to just that account.

The Worker itself doesn't need to be pre-created — the first `wrangler deploy` creates it using the `name` field from `wrangler.jsonc`.

### GitHub

Repo → Settings → Secrets and variables → Actions → add:

- `CLOUDFLARE_API_TOKEN` — the token from the previous step
- `CLOUDFLARE_ACCOUNT_ID` — visible in the Cloudflare dashboard sidebar

## DNS cutover

Zero-downtime sequence — nothing goes live until step 4. Roll back at any point by reverting nameservers at the registrar.

1. **Add `andycroll.com` to Cloudflare** ([guide](https://developers.cloudflare.com/fundamentals/manage-domains/add-site/)). Cloudflare scans your current DNS and imports what it finds. The scan isn't guaranteed to be complete — manually verify MX/SPF/DKIM/DMARC for email and any other subdomains (the existing CSP allows `*.andycroll.com`, so there may be records worth keeping). Leave the imported A/CNAME records for the apex and `www` pointing at Render for now.
2. **Attach the Worker to the apex.** Workers & Pages → `andycroll-com` → **Settings → Domains & Routes → Add → Custom Domain** → enter `andycroll.com`. Cloudflare creates the proxied DNS record and provisions a cert. The record sits in Cloudflare's DNS but doesn't serve traffic until nameservers cut over.
3. **Redirect `www` → apex** with a Single Redirect rule (preferred over adding `www` as a second Custom Domain — single canonical, no duplicate-content). Dashboard → `andycroll.com` zone → **Rules → Redirect Rules → Create rule**. Match `Hostname equals www.andycroll.com`; target `concat("https://andycroll.com", http.request.uri.path)` with status 301. [Single Redirects require a proxied DNS record on the source hostname](https://developers.cloudflare.com/rules/url-forwarding/single-redirects/create-dashboard/); the dashboard prompts you to create one — accept the prompt.
4. **Cut over at the registrar.** Cloudflare's onboarding page shows two assigned nameservers. Update your domain registrar to point at those. Propagation is usually under an hour but can take longer.
5. **Verify.** Once `dig +short andycroll.com` shows Cloudflare IPs:
   - `https://andycroll.com/ruby/use-class-names-…/` loads and the `/cdn-cgi/image/…` URLs return AVIF/WebP (not 404).
   - `https://www.andycroll.com/` 301s to the apex.
   - Email still works (send a test).
6. **Clean up.** Delete the `images.andycroll.com` DNS record (no longer needed). Decommission the Render service.
