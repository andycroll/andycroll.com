---
title: "Use StringInquirer for Readable Predicate Methods"
description: "The same pattern Rails uses for Rails.env.production?"
layout: article
category: ruby
date: 2026-02-10 09:00
image:
  base: "2026/use-stringinquirer-for-readable-predicate-methods"
  alt: "3D question marks scattered on light background"
  credit: "Vadim Bogulov"
  source: "https://unsplash.com/photos/Vq-Sqr7D_7k"
---

You've probably seen `Rails.env.production?` in your codebase to ensure that certain code only runs in production. Instead of having to compare strings, `Rails.env == "production"`, Rails wraps the string in an [`ActiveSupport::StringInquirer`](https://api.rubyonrails.org/classes/ActiveSupport/StringInquirer.html) so you get readable methods like `.production?` and `.development?`.

Active Support also adds an [`inquiry` method to `String`](https://api.rubyonrails.org/classes/String.html#method-i-inquiry) so you can use this same pattern in your own code.

## Instead of…

…comparing strings with `==`:

```ruby
class Writing < ApplicationRecord
  # category is a string: "story", "nursery_rhyme", "song", "article", "social_post"

  def online?
    category == "article" || category == "social_post"
  end
end
```

## Use…

…the `inquiry` method to ask questions of your string attributes:

```ruby
class Writing < ApplicationRecord
  def category = super.to_s.inquiry

  def online? = category.article? || category.social_post?
end
```

The overridden `category` getter calls `super` to get the original value, then wraps it in a `StringInquirer` via `.to_s.inquiry`. Now calling `.article?` checks whether the string equals `"article"`.

## Why?

The code reads like English. "Is the category an article?" becomes `category.article?` rather than `category == "article"`.

This is the same pattern Rails uses internally. When you write `Rails.env.production?`, you're calling a predicate method on a `StringInquirer`. Applying the pattern to your own code feels natural.

It works well with dynamic data such as API responses or CSV imports where defining an enum upfront isn't practical.

```ruby
status = api_response["status"].to_s.inquiry
status.pending?   #=> true if status == "pending"
status.complete?  #=> true if status == "complete"
```

## Why not?

If your values are a known, fixed set, prefer Rails enums:

```ruby
class Writing < ApplicationRecord
  enum :category, %w[story nursery_rhyme song article social_post].index_by(&:itself)
end

writing.article?       # same predicate methods
Writing.social_post    # scopes for free
writing.song!          # and bang assignment methods
```

Enums give you database-backed validation and automatic scopes. Use `StringInquirer` when the values are too dynamic for an enum, or when you're working with external data you don't control.

## Extra nuances

You might sometimes want a bare attribute call to return `nil`. With a `StringInquirer` it will always be `""`. Either adjust checks to look for `.blank?` rather than `.nil?` or modify the implementation using the [lonely operator](/ruby/rails-try-vs-safe-lonely-navigation-operator-ampersand-dot):

```ruby
def category = super.presence&.inquiry
```

However, this requires safe navigation (`&.`) when calling predicates, `category&.news?`, so you're exchanging more database-accurate nilness for ugly calls.
