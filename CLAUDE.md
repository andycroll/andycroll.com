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

**Ruby version**: 4.0.1 (see `.ruby-version`)

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

Deployed to a Cloudflare Worker named `andycroll-com` via `wrangler.jsonc` (static assets pointing at `_site`). The `.github/workflows/deploy.yml` workflow is `workflow_dispatch`-only — it runs `bundle exec jekyll build` under `LANG=C.UTF-8` and then `cloudflare/wrangler-action@v3 deploy`.

Prerequisites (one-time): `andycroll.com` zone on Cloudflare with Image Transformations enabled (paid), a Worker named `andycroll-com`, and repo secrets `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID`. Full setup steps in `README.md`.
