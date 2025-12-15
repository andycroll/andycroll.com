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
last_modified_at: 2018-12-01
---

Each Active Record model comes with the well-used ‘get me a single record’ scopes: `.first` and `.last`.

## Instead of…

…using the methods directly on the base ActiveRecord class.

```ruby
User.first
User.last
```


## Use…

…them only with ordered scopes. Ideally with named concepts.

### `app/models/user.rb`

```ruby
class User < ActiveRecord::Base
  scope :by_created, -> { order(created_at: :asc) }
  scope :earliest_created, -> { by_created.first }
  scope :most_recently_created, -> { by_created.last }
  # …
end

User.most_recently_created
```


## But why?

This is mostly about making the code more explicit.

The `.first` and `.last` methods, when called on a bare Active Record model scope, mean the 'lowest `id`' and the 'highest `id`'. However we colloquially use them to mean ‘created first’ and ‘created most recently’.

This is an accident of the default database configuration of Rails.

Objects in the database are created, by default, with an incrementing integer `id`. This means that ordering by this ascending `id` is the same as if we ordered by the `created_at` timestamp.

But using these scopes with no explicit order means you are ordering by '`id` assigned by the database', not by recency.

If you took my advice from a previous article about [using UUIDs for primary keys](/ruby/choose-uuids-for-model-ids-in-rails) the result of calling `.first` and `.last` might surprise you.

The default ordering is still on an Active Record object’s `id` which is now random. So when you create a `User` it is not automatically available as `User.last`.


### Why not?

Implementing this leads to more code and Rails’ conventions on this are long-standing. You might not feel this is worth it.

You’ll probably also need to add an index to `created_at` so you can keep your new scopes snappy.
