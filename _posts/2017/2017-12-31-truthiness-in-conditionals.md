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

Ruby’s conditional syntax is ‘truthy’, meaning that any statement in a conditional that evaluates to `nil` is considered to be equivalent to `false` and anything not-`nil` can be considered to be `true`.


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

Performing a `#nil?` check as part of a statement in a negative conditional, as in the first two examples (`unless` or `if !`), is often redundant. Any `nil` value is ‘falsey’, so you can achieve the same result with a positive conditional and no `#nil?` check.

Remove the `nil?` check and substitute the `unless` for an `if` (example 1) or remove the `!` (example 2) and end up with clearer code that means the same thing.

The syntax of `!!`, in the third example, is shorthand for turning any value (either ‘truthy’ or ‘falsey’) into the _actual boolean values_ `true` or `false`. However, given Ruby's ‘truthy’ conditionals performing this conversion is redundant.


## Why not?

This comes down to understandability. If you _really_ are checking for `nil` — perhaps you’re treating an empty array and `nil` in different ways — then, by all means, explicitly use the check.

---

This article has been [translated to Japanese](https://techracho.bpsinc.jp/hachi8833/2018_05_10/55817).
