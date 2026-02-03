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

You've probably seen `Rails.env.production?` in your codebase, to ensure some code only runs in production. Rails wraps the environment string in an [`ActiveSupport::StringInquirer`](https://api.rubyonrails.org/classes/ActiveSupport/StringInquirer.html), which lets you ask questions of a string value rather than comparing it directly.

Active Support adds an [`inquiry` method to `String`](https://api.rubyonrails.org/classes/String.html#method-i-inquiry) so you can use this pattern in your own code.

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

The pattern `def category = super.to_s.inquiry` overrides the getter. It calls `super` to get the original value, converts it to a string with `to_s`, then wraps it in a `StringInquirer`.

Now any predicate method you call checks if the string matches that name:

```ruby
"article".inquiry.article?      #=> true
"article".inquiry.story?        #=> false
"".inquiry.social_post?         #=> false
```

If you need `category` to return `nil` when the underlying value is blank, use `presence` and the [lonely operator](/ruby/rails-try-vs-safe-lonely-navigation-operator-ampersand-dot) instead:

```ruby
def category = super.presence&.inquiry
```

This requires safe navigation (`&.`) when calling predicates: `category&.news?`.

## Why?

The code reads like English. "Is the category an article?" becomes `category.article?` rather than `category == "article"`.

This is the same pattern Rails uses internally. When you write `Rails.env.production?`, you're calling a predicate method on a `StringInquirer`. Applying the pattern to your own code feels natural.

It works well with dynamic data—values from APIs, user input, or CSV imports—where defining an enum upfront isn't practical. The inquirer adapts to whatever string you give it.

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
