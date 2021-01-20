---
title: "Use Enhanced Memoization for false/nil with defined?"
description: "Memoizing false & nil results requires more formality"
layout: article
category: ruby
image:
  base: "2021/use-enhanced-memoization-for-false-nil-with-defined"
  alt: "true, false & nil word cloud"
---

One straightforward performance optimization we discussed using was [memoization using the `||=` operator](ruby/memoize-expensive-operations) however this isn't a solution in all cases.


## Instead of ...

...repeating potentially expensive calculations:

```ruby
class OldTimeySweetShop
  def any_jars_nearly_empty?
    @any_jars_nearly_empty ||= glass_jars.any? do |jar|
      jar.count_each_sweet_by_hand < 10
    end
  end
end
```


## Use...

...the `defined?` method with an early return.

```ruby
class OldTimeySweetShop
  def any_jars_nearly_empty?
    return @any_jars_nearly_empty if defined?(@any_jars_nearly_empty)
  
    @any_jars_nearly_empty = glass_jars.any? do |jar|
      jar.count_each_sweet_by_hand < 10
    end
  end
end
```


## Why?

Use of the `#defined?` method is technically the more "correct" way to perform memoization.

The `||=` (or equals) operator literally means:

```ruby
a || a = possibly_expensive_computation
```

A consequence of this is that if `a` is "false-y", meaning set to `nil` or `false`, then right-hand side of the `||` is executed. This is a big issue if the expensive computation can return false, it will be run every time the method is used, completely circumventing the improvement we are attempting.

I've used `Enumerable#any?` deliberately above to illustrate that this technique can be useful in the output of methods that loop over large datasets and return a boolean or `nil` result.


## Why not?

Often, a memoized result won't be `nil` or `false` and in that case this style is undoubtably less attractive to read when you come back to it.
