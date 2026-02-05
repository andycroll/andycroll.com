---
title: "Customize Model URLs with to_param"
description: "Override to_param to control how your Rails models appear in URLs—use slugs, hide IDs, or combine both."
layout: article
category: ruby
date: 2026-02-17 06:00
image:
  base: "2026/to-param-seo-friendly-urls"
  alt: "Wooden signposts pointing in different directions on a beach"
  credit: "Sara Kurfeß"
  source: "https://unsplash.com/photos/arrow-signs-ELuA9ispQHo"
---

Rails models default to using their ID in URLs: `/articles/42`. The `to_param` method lets you customize this—use a slug, hide the ID, or combine both for readable URLs. Exposing IDs isn't dangerous if you scope access properly, but you might want cleaner paths.

## Instead of...

...exposing IDs in your URLs:

```ruby
redirect_to article_path(@article)
# => "/articles/42"
```

## Use...

...the `to_param` method to return a slug instead:

```ruby
class Article < ApplicationRecord
  before_save { self.slug = title.parameterize }

  def to_param = slug
end

redirect_to article_path(@article)
# => "/articles/understanding-rails-extensions"
```

Then find records by slug in your controller:

```ruby
def set_article
  @article = Article.find_by!(slug: params[:id])
end
```

For reliable lookups with readable URLs, prefix the slug with the ID:

```ruby
def to_param
  "#{id}-#{title.parameterize}"
end

# => "/articles/42-understanding-rails-extensions"
```

The ID lookup just works—`"42-understanding-rails-extensions".to_i` returns `42`, so `Article.find(params[:id])` needs no parsing.

## Why?

Rails URL helpers call `to_param` automatically when generating URLs. Override it to create cleaner, more descriptive paths without changing controller code.

Descriptive URLs are easier to read in logs, analytics, and when shared. They give users context about content before clicking. For content-heavy sites, slug-based URLs can help with SEO.

Hiding IDs also keeps URLs stable if you ever migrate databases or change ID schemes.

## Why not?

Pure slug URLs require uniqueness on the relevant column, an index in the database, and method changes everywhere you `find` the model. If slugs can change, you'll need redirects for old URLs.

For production apps, consider [friendly_id](https://github.com/norman/friendly_id)—it handles slug generation, duplicates, history tracking, and scoped slugs. Or try [prefixed_ids](https://github.com/excid3/prefixed_ids) for Stripe-style encoded IDs like `user_5vJjbzXq9KrLEMm32iAnOP0xGDYk6dpe` that hide sequential IDs without needing slugs.

The ID-prefixed approach avoids uniqueness issues but still exposes the ID. Hiding IDs entirely means extra complexity in exchange for security through obscurity—a trade-off worth considering carefully.
