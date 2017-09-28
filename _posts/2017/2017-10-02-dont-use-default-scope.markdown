---
title: "Don’t use default_scope. Ever."
layout: article
category: ruby
image: '2017/dont-use-default-scope'
imagealt: 'default_scope code'
description: ''

---

## Instead of…

```ruby
class Post < ActiveRecord::Base
  default_scope { where(hidden: false) }
end
```

## Use…

Explicit scopes.

### `app/models/post.rb`

```ruby
class Post < ActiveRecord::Base
  scope, :published -> { where(hidden: false) }
end
```

### then use like…

```ruby
Post.published
```

## But why?

This is particularly dangerous with `where` clauses, or the situation when you say to yourself ‘I will always need this companion model so I’ll use a `join` or `include` scope’.

Don’t.

Default scope affects your model initialization. If you have a default scope, your `Post.new` is defaulted to `hidden = false` whether you were expecting it or not.

Ordering is less of an issue within a `default_scope`, but in order to remove the default ordering you have to use `unscoped` which removes _all_ applied conditions including associations.

` Post.first.comments.unscoped` would return every comment in your database, not just those for the first `Post`.

Using `default_scope` will lead to many hours of bug hunting. Don’t do it to yourself.


### Why not?

Seriously. Trust me on this one. It will bite you.
