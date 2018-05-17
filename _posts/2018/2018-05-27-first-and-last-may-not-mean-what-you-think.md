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

Each ActiveRecord model comes with the well used ‘get me a single record’ scopes; `.first` & `.last`.

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

I’ll admit, this is a subtle one. My argument is mostly about making the code more explicit.

If you’re using the bare `.first` and `.last` methods on an bare ActiveRecord model scope you are relying heavily on the Rails convention of an incrementing integer ID.

Those methods are thus colloquially used to mean ‘created first’ and ‘created most recently’. It's only an accident of Rails default design that sorting by ascending `id` is same order as the ascending `created_at` timestamp.

You might remember I advocated [using UUIDs for primary keys](/2017/choose-uuids-for-model-ids-in-rails) in a previous article, this pairs up nicely don’t you think?


### Why not?

It’s more code and Rail’s conventions on this are long standing. You might not feel this is worth it.
