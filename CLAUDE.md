# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal website and blog for Andy Croll (andycroll.com), built with Jekyll and deployed to Netlify. The site features Ruby/Rails technical articles under the "One Ruby Thing" brand, plus personal/conference content.

## Commands

```bash
# Development server (with hot reload)
bundle exec jekyll serve

# Development server (with hot reload and include future dated articles)
bundle exec jekyll serve --future

# Build for production
JEKYLL_ENV=production jekyll build

# Build with future-dated posts (for previews)
JEKYLL_ENV=development jekyll build --future
```

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

**Images**: Production images served from `https://images.andycroll.com`, local `/images/` in development. Image URLs use query parameters for responsive sizing (e.g., `?width=1024`).

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

Hosted on Render. Production builds automatically on push to main. Auto deploys every six hours using igthub actions to trigger a deploy hook.
