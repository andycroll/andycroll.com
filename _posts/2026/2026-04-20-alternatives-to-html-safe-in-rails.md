---
title: "Avoid html_safe with Tag Helpers, safe_join, and sanitize"
description: "Rails has better tools than html_safe for building HTML safely in your helpers and views."
layout: article
category: ruby
date: 2026-04-20 09:00
image:
  base: "2026/avoid-html-safe"
  alt: "Yellow and black striped textile"
  credit: "Ash Amplifies"
  source: "https://unsplash.com/photos/yellow-and-black-striped-textile-KPDDc1DeP4Y"
---

When you need to build HTML outside of a template, it's tempting to concatenate strings and call `html_safe` on the result. This bypasses Rails's built-in [XSS protection](/ruby/2023/07/17/beware-of-raw-erb/) entirely: any user input in that string goes straight to the browser unescaped.

The good news is you almost never need `html_safe`. Rails provides three underappreciated tools that handle escaping for you.

## Instead of…

…calling `html_safe` on strings you've built by hand:

```ruby
def status_badge(label, color)
  "<span class=\"badge badge-#{color}\">#{label}</span>".html_safe
end
```

```ruby
def formatted_address(user)
  [user.street, user.city, user.postcode].compact.join("<br>").html_safe
end
```

```ruby
def render_comment(comment)
  comment.body_html.html_safe
end
```

## Use…

…the right tool for each situation.

When you need to **build HTML elements**, use `tag` helpers:

```ruby
def status_badge(label, color)
  tag.span(label, class: "badge badge-#{color}")
end
```

The [`tag` helper](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html) escapes the content and attributes automatically. It returns an HTML-safe string without you having to think about it.

When you need to **join fragments** that mix safe HTML with potentially unsafe text, use `safe_join`:

```ruby
def formatted_address(user)
  safe_join([user.street, user.city, user.postcode].compact, tag.br)
end
```

[`safe_join`](https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-safe_join) escapes any unsafe strings in the array and returns an HTML-safe result. It's `Array#join` with protection built in.

When you need to **accept user-provided HTML** but strip dangerous tags, use `sanitize`:

```ruby
def render_comment(comment)
  sanitize(comment.body_html)
end
```

[`sanitize`](https://api.rubyonrails.org/classes/ActionView/Helpers/SanitizeHelper.html#method-i-sanitize) keeps safe tags like `<p>`, `<strong>`, and `<em>` while stripping `<script>`, event handlers, and other XSS vectors. You can customise the allowed tags and attributes, but beware of straying past the defaults — they are battle-tested and loosening them is a [footgun](https://en.wiktionary.org/wiki/footgun).

## Why?

Each of these tools lets Rails manage HTML safety for you. You describe what you want — an element, a joined list, sanitised content — and the framework handles the escaping.

`html_safe` does the opposite. It tells Rails "trust this string, don't escape it". That's a promise _you_ have to keep, and it's easy to break when the inputs change or a future developer doesn't realise user data flows through that path. Ask your friendly security consultant or penetration testing organisation why this is a bad idea.

The mental model is simple. Need an HTML element? `tag`. Joining fragments? `safe_join`. Accepting rich text? `sanitize`. If none of those fit, you probably need a partial or a component, not a string.

## Why not?

There are legitimate uses of `html_safe`. Some gems, like [`pagy`](https://github.com/ddnexus/pagy), return pre-built HTML strings that are safe by construction. Calling `html_safe` on their output is fine because the gem controls the content.

You might also see `html_safe` on strings that are genuinely static with no user input, like `"&nbsp;".html_safe`. That's harmless, but you can include the actual Unicode character instead — `"\u00A0"` gives you a non-breaking space without needing `html_safe` at all. That is ugly as hell though, so it's your call!

The key question is always: could user input end up in this string? If the answer is yes, or _even maybe_, reach for `tag`, `safe_join`, or `sanitize` instead.
