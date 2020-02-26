---
title: "‘Fix’ first & last by explicitly setting implicit ordering"
description: "When UUIDs and Rails make a mess"
layout: article
category: ruby
image:
  base: '2020/fix-first-last-explicitly-set-implicit-ordering-in-rails-with-uuids'
  alt: "Pins on a red mat"
  credit:  Jeff Frenette
  source: "https://unsplash.com/photos/Y_AWfh0kGT4"
---

[Using UUIDs as primary keys](/ruby/choose-uuids-for-model-ids-in-rails) has many benefits. However, it causes issues with Rails's implicit ordering.

In a previous article, I suggested [using named scopes alongside `first` and `last`](/ruby/first-and-last-may-not-mean-what-you-think), but there is now an easier way to re-enable the default behaviour of Active Record.


## Instead of...

...avoiding `#first` & `#last` when using non-sequential `id`s on an Active Record model, or using the extra specificity provided by a named scope...


## Use

...`implicit_order_column` within your model and aim it at the automatically generated `created_at` column.

```ruby
class Coffee < ApplicationRecord
  self.implicit_order_column = "created_at"
end
```


## Why?

There are major benefits to using UUIDs in your database: uniqueness, assignability, and security.

With this one-line change you also retain the benefits of Rails’ `.first` and `.last` helper methods, provided you assign the `implicit_order_column` to the `created_at` timestamp.

My friend [Tekin](https://tekin.co.uk) came up with the idea and [implemented it in Rails](https://github.com/rails/rails/pull/34480)!


## Why not?

This is a Rails 6 feature. Prior versions of Rails still require the [explicit ordering implementation](/ruby/first-and-last-may-not-mean-what-you-think) I previously explained. You may prefer using the explicit ordering approach for improved clarity.

If you still do not use UUIDs in your data model, perhaps your database doesn’t support them, there’s little point in using this.

If the specified column isn’t unique you cannot predict the order of the results that share the same value in the implicitly ordered column. The results will however remain in the same order as there has been an [enhancement to the implementation](https://github.com/rails/rails/pull/37626).
