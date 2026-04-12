---
title: "Use Rails Combined Credentials"
description: "Rails 8.1 adds Rails.app.creds to unify ENV variables and encrypted credentials behind a single API."
layout: article
category: ruby
date: 2026-04-13 06:00
image:
  base: "2026/use-rails-combined-credentials"
  alt: "A secret door opened inside a library"
  credit: "Stefan Steinbauer"
  source: "https://unsplash.com/photos/opened-secret-door-inside-library-HK8IoD-5zpg"
---

To deal with secrets and credential handling most Rails apps have ended up with a hotchpotch of `ENV.fetch` calls and `credentials.dig` lookups throughout the codebase, depending on where each secret lives.

Rails 8.1 fixes this.

## Instead of...

...mixing ENV and credentials lookups:

```ruby
class StripeChargeService
  def initialize
    @api_key = ENV.fetch("STRIPE_API_KEY")
    @webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)
    @price_id = ENV.fetch("STRIPE_PRICE_ID") { Rails.application.credentials.dig(:stripe, :price_id) }
  end
end
```

## Use...

...the combined credentials API:

```ruby
class StripeChargeService
  def initialize
    @api_key = Rails.app.creds.require(:stripe, :api_key)
    @webhook_secret = Rails.app.creds.require(:stripe, :webhook_secret)
    @price_id = Rails.app.creds.require(:stripe, :price_id)
  end
end
```

`require` raises a `KeyError` if the key is missing from all backends. For optional values, use `option`:

```ruby
Rails.app.creds.option(:appsignal, :push_api_key, default: nil)
# Returns nil if missing — AppSignal just won't report
```

To keep production secrets separate, run `bin/rails credentials:edit --environment production`. This creates a separate encrypted file with its own key:

```
config/credentials.yml.enc         ← shared (dev/test)
config/master.key                  ← decrypts the shared file

config/credentials/production.yml.enc  ← production only
config/credentials/production.key      ← decrypts production
```

If `production.yml.enc` exists, Rails uses it exclusively in production — there's no inheritance from the shared file, so duplicate any keys you need. To decrypt in production, set `RAILS_MASTER_KEY` in your hosting provider to the contents of `production.key`.

## Why?

`Rails.app.creds` checks ENV first, then falls back to encrypted credentials. You don't need to know or care where a value is stored.

Nested keys like `:stripe, :api_key` map to double-underscored ENV names (`STRIPE__API_KEY`). A single key like `:postmark_api_token` checks `ENV["POSTMARK_API_TOKEN"]`.

This means you can move secrets between ENV and encrypted credentials without changing application code. Deploying to a provider that injects secrets via ENV? It just works. Want to move a key into the encrypted file instead? Remove the ENV variable and add it to your credentials. Your code stays the same.

I've [previously recommended](/ruby/wrap-your-environment-variables-in-a-settings-object/) wrapping ENV in a custom Settings object. This built-in approach is better — the same clean interface with the added fallback to encrypted credentials.

## Why not?

Rails 8.1+ only. If you're on an older version, a [custom Settings wrapper](/ruby/wrap-your-environment-variables-in-a-settings-object/) still works well.

You can also create `development.yml.enc` and `test.yml.enc`, but I think the shared file plus a production override is clearer — and you shouldn't be calling real APIs in your test environment anyhow.

Keep separate encryption keys for each environment. You could share one, but a leaked development key shouldn't expose production secrets.
