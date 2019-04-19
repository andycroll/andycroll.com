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

The use of `where.not` when building Active Record scopes can help you to elegantly specify scopes where an attribute does not have a specific value.

However the abstraction has some quirks if you have fields that can be `NULL` in your database (`nil` in Ruby).


## Instead of…

…expecting `where.not` to return `nil` values:

```ruby
non_soy_options = Coffee.where.not(milk: "Soy")
```


## Use…

…an `or` clause to explicitly request the `nil` values.

```ruby
non_soy_options = Coffee.where.not(milk: "Soy").or(Coffee.where(milk: nil))
```


## But why?

Of course this all depends on whether the answer you're looking for is expected to include nil values!

This is because in SQL the results of `WHERE milk = "Soy"` aren’t the inverse of `WHERE milk != "Soy"`. Neither of them include the case `WHERE milk IS NULL`


## Why not?

In some cases this isn’t the logic you want. So in that case... I guess, don’t use it? :-)
