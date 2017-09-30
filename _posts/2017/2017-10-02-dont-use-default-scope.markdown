---
title: "Don’t use default_scope. Ever."
description: 'Using `default_scope` will lead to many hours of bug hunting. Don’t do it to yourself.'
layout: article
category: ruby
image:
  base: '2017/dont-use-default-scope'
  alt: 'default_scope code'
---

A `default_scope` can be applied to a model, if you would like that scope to be applied across all queries on the model. See more in the  [ActiveRecord Query Guide](http://guides.rubyonrails.org/active_record_querying.html#applying-a-default-scope) and [Rails docs](http://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope).

-----

Where you have a blog system with posts that can be set to be hidden, for when you are writing a draft.

## Instead of…

...`default_scope`.

```ruby
# app/models/post.rb
class Post < ActiveRecord::Base
  default_scope { where(hidden: false) }
end
```

## Use…

...explicit scopes.

```ruby
# app/models/post.rb
class Post < ActiveRecord::Base
  scope, :published -> { where(hidden: false) }
end
```

...and use like…

```ruby
Post.published
```

## But why?

Two reasons. Both to do with later confusion and bug hunting.

Adding a default scope _also_ affects your model initialization. If you have a default scope (as in the example), your `Post.new` is defaulted to `hidden = false` whether you were expecting it or not.

Trying _not_ to use your defined default scope is a pain. To remove the `default_scope` when you don't need it you have to use the `unscoped` scope (!) which removes _all_ applied conditions including associations.

i.e. `Post.first.comments.unscoped` would return every comment in your database, not just those for the first `Post`.

The explicit use of named scopes is a clearer solution than a `default_scope` that might lead to confusion or complexity at a later date. Using `default_scope` will lead to many hours of bug hunting. Don’t do it to yourself.


### Where might I use it?

Seriously. Trust me on this one. It will bite you.
