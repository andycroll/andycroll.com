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

The `.first` and `.last` methods, when called on a bare Active Record model scope, are colloquially used to mean ‘created first’ and ‘created most recently’.

It’s only an accident of Rails default design that sorting by ascending `id` is the same order as the ascending `created_at` timestamp.

Using these scopes with no explicit order means you are relying heavily on the Rails convention of an incrementing integer `id`.

You might remember I advocated [using UUIDs for primary keys](/2017/choose-uuids-for-model-ids-in-rails) in a previous article. This pairs up nicely don’t you think?


### Why not?

Implementing this leads to more code and Rails’ conventions on this are long-standing. You might not feel this is worth it.
