---
title: Be Aware of nil values when using where.not()
description: Strange Think
layout: article
category: ruby
image:
  base: '2019/be-aware-of-nil-values-when-using-where-not'
  alt: 'Half-finished painted wall'
  source: "https://unsplash.com/photos/oBb-Y26PJgg"
  credit: "Samuel Zeller"
---

The use of `where.not` when building Active Record scopes can help you to elegantly specify scopes for cases where an attribute does not have a specific value.

However the abstraction has some quirks if the attribute you’re querying can be `NULL` in your database (`nil` in Ruby). The `where.not` scope doesn’t automatically return `nil` values unless you specify that you want them.


## Instead of…

…expecting `where.not` to return `nil` values:

```ruby
non_oat_options = Coffee.where.not(milk: "Oatly")
```


## Use…

…an `or` clause to explicitly request the `nil` values.

```ruby
non_oat_options = Coffee.where.not(milk: "Oatly").or(Coffee.where(milk: nil))
```

…alternatively you can pass an array of options to the (negated) `where` scope that includes a `nil` value.

```ruby
non_oat_options_2 = Coffee.where.not(milk: [nil, "Oatly"])
```


## But why?

Of course this all depends on whether you are expecting the answer to include those nil values!

The positive use, `where(milk: "Oatly")`, as expected, will not return `nil` values, and you would think that `where.not(milk: "Oatly")` would be the complete inverse: _but it isn’t_.

This is because the SQL result of a `where.not` scope is SQL’s `!=` operator, which doesn't return `NULL` values from the database.


## Why not?

In some cases this isn’t the logic you want. So in that case... I guess, don’t use it? :-)
