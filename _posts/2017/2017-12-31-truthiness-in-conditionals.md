---
title: 'Truthiness in Conditionals'
description: 'if not not nil?'
layout: article
category: ruby
image:
  base: '2017/truthiness-in-conditionals'
  alt: 'Truth'
  source: 'https://unsplash.com/photos/Aa2h3S3E47k'
  credit: 'Jarrod Fitzgearlds'
---

Ruby’s conditional syntax is ‘truthy’, meaning that anything that is `nil` is also considered to be `false` and anything not-`nil` can be considered to be `true`.


## Instead of…

...overcomplicating your conditions.

```ruby
# Example 1
unless something.nil?
  # do something
end

# Example 2
if !something.nil?
  # do something
end

# Example 3
if !!something
  # do something
end
```


## Use…

```ruby
# Instead of Examples 1,2 & 3
if something
  # do something
end
```


## But why?

Performing a `#nil?` check in a negative conditional, as in the first two examples, is often redundant as any non-`nil` value is `true`. You can remove the `nil?` check and substitute the `unless` for an `if` or remove the `!` and end up with clearer code that means the same thing.

The syntax of `!!`, in the third example, is shorthand for turning any value (either ‘truthy’ or ‘falsey’) into the _actual boolean values_ `true` or `false`. However, given Ruby's ‘truthy’ conditionals performing this conversion is redundant.


## Why not?

This comes down to understandability. If you _really_ are checking for `nil`, then by all means explicitly use the check.
