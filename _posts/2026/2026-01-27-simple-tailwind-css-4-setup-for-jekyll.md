---
title: "Simple Tailwind CSS 4 Setup for Jekyll"
description: "A minimal setup for Tailwind CSS 4 in Jekyll using the jekyll-tailwind gem"
layout: article
category: ruby
date: 2026-01-27 09:00
image:
  base: "2026/simple-tailwind-css-4-setup-for-jekyll"
  alt: "Black and white airplane flying in the sky"
  credit: "Sander Weeteling"
  source: "https://unsplash.com/photos/iGDg_f_mlWo"
---

Tailwind CSS 4 changed how configuration works. The JavaScript config file has been replaced by CSS-based configuration using `@theme` directives and uses the `tailwind` CLI to shake down the generated tailwind classes and minify. Here's how to set it up with [Jekyll](https://jekyllrb.com).

## The Setup

Changes to four files, plus one more step if you want plugins.

### Gemfile

```ruby
gem "jekyll-tailwind", group: [:jekyll_plugins]
```

Run `bundle install` to fetch the gem. The [`jekyll-tailwind`](https://github.com/vormwald/jekyll-tailwind) gem handles everything. No separate build pipeline, no PostCSS config, no watching for changes. It hooks into Jekyll's build process.

Under the hood, it uses [`tailwindcss-ruby`](https://github.com/flavorjones/tailwindcss-ruby)---the same gem that powers Tailwind in Rails.

### _config.yml

```yaml
plugins:
  - jekyll-tailwind

tailwind:
  input: assets/css/app.css
  minify: true
```

Point it at your CSS file and enable minification for production builds.

### Tailwind Plugins (optional)

If you want Tailwind plugins like Typography or Forms, install them with npm:

```bash
npm install @tailwindcss/typography @tailwindcss/forms
```

This requires Node.js on your system. If you're only using core Tailwind utilities, skip this step.

For blogs, `@tailwindcss/typography` is particularly useful. It provides `prose` classes that style your markdown content with sensible defaults for headings, paragraphs, lists, code blocks, and blockquotes:

```html
<article class="prose prose-lg">
  {{ content }}
</article>
```

### assets/css/app.css

```css
@import "tailwindcss";
/* @plugin "@tailwindcss/typography"; */
/* @plugin "@tailwindcss/forms"; */

@theme {
  --font-serif: "Georgia", serif;
  --breakpoint-sm: 400px;
  --breakpoint-md: 600px;
  --breakpoint-lg: 800px;
}
```

This is where Tailwind 4's changes shine. The `@theme` block replaces `tailwind.config.js`. Custom fonts, breakpoints, colors, spacing---all defined in CSS.

Plugins use the `@plugin` directive instead of being listed in a JavaScript config.

### _layouts/default.html

Include the stylesheet in your [layout's](https://jekyllrb.com/docs/front-matter/) `<head>`:

```html
<link href="{{ "/assets/css/app.css" | relative_url }}" rel="stylesheet">
```

## Why This Works

The `jekyll-tailwind` gem runs Tailwind's CLI during Jekyll's build. When you run `bundle exec jekyll serve`, it:

1. Processes your input CSS file
2. Scans your templates for Tailwind classes
3. Generates optimized CSS
4. Outputs to `_site/assets/css/app.css`

Hot reload works. Change a class in a template, save, and the CSS rebuilds.

## Why Not?

If you need complex PostCSS plugins beyond what Tailwind provides, you might want a separate build pipeline. But for most Jekyll sites, this setup handles everything.
