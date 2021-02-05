---
title: "Use Enhanced Memoization for false/nil with defined?"
description: "Memoizing false & nil results requires more formality"
layout: article
category: ruby
image:
  base: "2021/use-enhanced-memoization-for-false-nil-with-defined"
  alt: "true, false & nil word cloud"
---

[Memoization using the `||=` operator](ruby/memoize-expensive-operations) is a useful and straightforward performance optimisation. However, this isn't a suitable solution for cases when the expensive operation might result in `false` or `nil`.


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

A consequence of this is that if `a` is "false-y", meaning set to `nil` or `false`, then the right-hand side of the `||` is executed. This is potentially a big issue because if the expensive computation is legitimately returning `false`, it will be run every time the method is used, completely circumventing the improvement we are attempting.

I've used `Enumerable#any?` above to illustrate that this `defined?`-based technique can be useful to improve performance for methods that loop over large datasets and might return a boolean or `nil` result.


## Why not?

Often, a memoized result won't be `nil` or `false`, and in that case this style is undoubtably more visually noisy to read, and possibly trickier to understand, when you come back to it later on.

### Beware Threads!

You should be careful when using memoization in a high-throughput, threaded Ruby environment. You probably are. `sidekiq` is threaded and many Ruby web servers are as well.

When your code is reaching _outside_ of the Ruby interpreter (e.g. reusable database connections, file handling, writing to a data store, manually creating background threads) it is possible to introduce race conditions if your code is called by multiple threads at the same time. However, you’re unlikely to be doing this in the course of a day-to-day application. Still, it is a possible source of bugs, so be aware!

Hat tip to Ivo on this one, he's resolved [bugs in open source projects](https://github.com/DataDog/dd-trace-rb/pull/1329) that demonstrate this issue. You can see his recorded talk on [spotting unsafe ruby patterns](https://ivoanjo.me/blog/2018/10/13/spotting-unsafe-ruby-patterns/) which dives into the details.
