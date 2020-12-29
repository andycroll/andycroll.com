---
title: "Don’t use default_scope. Ever."
description: 'Using `default_scope` will lead to many hours of bug hunting. Don’t do it to yourself.'
layout: article
category: ruby
image:
  base: '2017/dont-use-default-scope'
  alt: 'default_scope code'
---

When you would like a scope to be applied across all queries on a model, you can use `default_scope`. See more in the [ActiveRecord Query Guide](https://guides.rubyonrails.org/active_record_querying.html#applying-a-default-scope) and [Rails docs](https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope).

-----

Where you have a blog system with posts that can be set to be hidden, for when you are writing a draft.

## Instead of…

…`default_scope`.

```ruby
# app/models/post.rb
class Post < ActiveRecord::Base
  default_scope { where(hidden: false) }
end
```

## Use…

…explicit scopes.

```ruby
# app/models/post.rb
class Post < ActiveRecord::Base
  scope, :published -> { where(hidden: false) }
end
```

…then you can do…

```ruby
Post.published
```

## But why?

Two reasons. Both to do with avoiding later confusion and bug hunting.

Adding a default scope affects your model initialization. In the example, `Post.new` is defaulted to `hidden = false` whether you are expecting it or not.

Trying _not_ to use your defined default scope is a pain. To remove the `default_scope` when you don't need it you have to use the `unscoped` scope (!) which removes _all_ applied conditions including associations.

i.e. `Post.first.comments.unscoped` would return every comment in your database, not just those for the first `Post`.

The explicit use of named scopes is a clearer solution. Using `default_scope` will lead to many hours of bug hunting. Don’t do it to yourself.


### Where might I use it?

Seriously. Trust me on this one. It will bite you.
