---
title: Active Record’s first and last may not mean what you think
description: 'Naming truly is an art'
layout: article
category: ruby
image:
  base: '2018/first-and-last-may-not-mean-what-you-think'
  alt: 'Running track'
  source: 'https://unsplash.com/photos/52p1K0d0euM'
  credit: 'Austris Augusts'
---

Each Active Record model comes with the well-used ‘get me a single record’ scopes: `.first` and `.last`.

## Instead of…

...using the methods directly on the base ActiveRecord class.

```ruby
User.first
User.last
```


## Use…

...them only with ordered scopes. Ideally with named concepts.

### `app/models/user.rb`

```ruby
class User < ActiveRecord::Base
  scope :by_created, -> { order(created_at: :asc) }
  scope :earliest_created, -> { by_created.first }
  scope :most_recently_created, -> { by_created.last }
  # ...
end

User.most_recently_created
```


## But why?

This is mostly about making the code more explicit.

The `.first` and `.last` methods, when called on a bare Active Record model scope, mean the 'lowest `id`' and the 'highest `id`'. However we colloquially use them to mean ‘created first’ and ‘created most recently’.

Objects in the database are created, by default, with an incrementing integer `id`. This means that sorting by ascending `id` is the same order as the ascending `created_at` timestamp.

Using these scopes with no explicit order means you are ordering by `id`, not by recency.

If you took my advice from a previous article about [using UUIDs for primary keys](/2017/choose-uuids-for-model-ids-in-rails) the result of calling `.first` and `.last` might surprise you, because the default ordering is still on an object’s `id` and that `id` is now random.


### Why not?

Implementing this leads to more code and Rails’ conventions on this are long-standing. You might not feel this is worth it.
