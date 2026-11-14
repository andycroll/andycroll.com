# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal website and blog for Andy Croll (andycroll.com), built with Jekyll and deployed to Cloudflare Workers (static assets). The site features Ruby/Rails technical articles under the "One Ruby Thing" brand, plus personal/conference content.

## Commands

```bash
# Development server (with hot reload)
bundle exec jekyll serve

# Development server (with hot reload and include future dated articles)
bundle exec jekyll serve --future

# Build for production
JEKYLL_ENV=production bundle exec jekyll build

# Build with future-dated posts (for previews)
JEKYLL_ENV=development bundle exec jekyll build --future

# Create a new post (jekyll-compose)
bundle exec jekyll post "Post Title"
```

**Ruby version**: see `.ruby-version`

## Architecture

**Static Site Generator**: Jekyll with these plugins:
- `jekyll-tailwind` - Tailwind CSS 4 integration (processes `assets/css/app.css`)
- `jekyll-compose` - Post creation helpers
- `jekyll-redirect-from` - URL redirects
- `jekyll-sitemap` - Auto-generated sitemap

**Styling**: Tailwind CSS 4 with `@tailwindcss/typography` and `@tailwindcss/forms` plugins. Custom theme defined in `assets/css/app.css` with serif font and custom breakpoints.

**Content Structure**:
- `_posts/YYYY/` - Blog posts organized by year, using front matter for metadata
- `_layouts/` - `default.html` (base) and `article.html` (blog posts)
- `_includes/` - Reusable components (email signup, project promos, footer)

**Images**: All raster images live in `/images/` in the repo and ship in `_site/`. In production they are routed through Cloudflare Image Transformations via the `_includes/cf_image.html` partial, which prepends `/cdn-cgi/image/format=auto,width=…/` to the path. In development the raw `/images/...` path is used so `jekyll serve` resolves files locally. SVGs are emitted as-is; only raster sources should go through `cf_image`.

**Categories**: Posts use `category: ruby` for Ruby/Rails content. The homepage displays recent Ruby posts prominently.

## Uses

`/uses/` lists the things Andy uses. Each thing is one file in `_uses/<section>/`, where `<section>` matches `uses_section` on a page in `uses/` (coffee, bags, carry, software, hardware, fun, home). Being in the folder puts it on the page. The body is a paragraph or two on why; when something changes, edit the body to say so, as with an updated post.

Dates follow post conventions: date the filename (`_uses/coffee/2026-11-20-comandante-c40.md`) or set `date` when a thing is new, and set `last_modified_at` when you edit it meaningfully. Leave things undated when they were already in use before /uses/ launched.

```yaml
---
title: "Comandante C40"
link: "https://..."              # optional
affiliate: true                  # optional; marks link as an affiliate link
image:                           # optional
  base: "uses/comandante-c40"    # photo: /images/uses/comandante-c40.jpg; icon: .png
  alt: "Alt text"                # defaults to the title
  kind: icon                     # optional; defaults to the section page's image_kind, else photo
last_modified_at: 2027-01-10     # optional; latest meaningful edit
retired: 2027-03-01              # optional; moves it to "No longer using"
published: false                 # optional; draft, as with posts
---
```

Photos keep their own shape (never cropped): above the text on phones (up to 14rem), floated right at 40% of the column from `md`, capped at 17rem from `lg`. App icons are transparent PNGs shown at 56px at the end of the title row; `uses/software.md` sets `image_kind: icon`. `/uses/` lists each thing with a 40px version of its picture.

`_plugins/uses.rb` turns each `date`, `last_modified_at` and `retired` into `site.data.uses_updates`. These are listed under Updates on `/uses/` and merged into `index.xml`/`rss.xml` as entries that link to the thing on its section page and carry its current text. There are no separate pages for updates. Each edit with a new `last_modified_at` reaches the feed as its own entry; the Updates list shows only the latest edit per thing. Future dates stay hidden until that day's build, like posts.

`/now/` is in the feeds too (`_plugins/now_in_feed.rb`): bump `date` (or set `last_modified_at`) in `now.md` and the rewrite goes out as a new entry.

## Share cards

Every post and page at a directory URL has a 1200×630 share card at `/og/<url>.jpg` (`/og/index.jpg` for the home page), used as its `og:image`/`twitter:image` by `head.html`. `_plugins/og_cards.rb` sets `og_image` on each page; set `og_card: false` to opt a page out. Cards are drawn at deploy, not committed: a build with `OG_CARDS=1` also renders each card as a page at `/og-cards/<url>/` (`_layouts/og_card.html`), then `bin/og-cards` screenshots them with headless Chrome (Ferrum) into `_site/og/` and deletes the card pages. Locally:

```bash
OG_CARDS=1 bundle exec jekyll build && bin/og-cards   # CHROME=/path/to/chrome if not found
```

The card has four designs: posts and pages with a hero image (hero as the top band, title, One Ruby Thing or Andy Croll wordmark, date), the home page (bio and headshot), /uses/ pages (title, description and the section's first pictures), and text-only for everything else. All card text is Merriweather so the result doesn't depend on the machine's fonts. The `Jekyll Tests` workflow also draws the cards and uploads them as the `share-cards` artifact, so a PR's cards can be checked before deploy.

## Post Front Matter

```yaml
---
title: "Post Title"
description: "Brief description"
layout: article
category: ruby
date: 2025-01-01 09:00
image:
  base: "2025/image-name"  # without extension
  alt: "Alt text"
  credit: "Photographer Name"
  source: "https://unsplash.com/..."
---
```

## Deployment

Deployed to a Cloudflare Worker named `andycroll-com` via `wrangler.jsonc` (static assets pointing at `_site`). The `.github/workflows/deploy.yml` workflow runs after `Jekyll Tests` succeeds on `main`, daily at 02:15 UTC, and on `workflow_dispatch` — it runs `bundle exec jekyll build` under `LANG=C.UTF-8` with `OG_CARDS=1`, draws the share cards with `bin/og-cards`, and then runs `cloudflare/wrangler-action@v4 deploy`.

Prerequisites (one-time): `andycroll.com` zone on Cloudflare with Image Transformations enabled (paid), a Worker named `andycroll-com`, and repo secrets `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID`. Full setup steps in `README.md`.
