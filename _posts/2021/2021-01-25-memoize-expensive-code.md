---
title: "Memoize Expensive Code"
description: "The ||= operator can provide significant performance improvements"
layout: article
category: ruby
image:
  base: '2021/memoize-expensive-code'
  alt: "Red Floppy Disk"
  credit:  Fredy Jacob
  source: "https://unsplash.com/photos/t0SlmanfFcg"
---

Memoization is a performance optimization where the result of a slow or non-performant piece of code is temporarily stored, and when the expensive code is called again, the stored value is returned.

## Instead of ...

...repeating potentially expensive calculations:

```ruby
class OldTimeySweetShop
  def average_sweets_per_jar
    sweet_count / glass_jars.count
  end

  def sweet_count
    glass_jars.sum do |jar|
      jar.count_each_sweet_by_hand
    end
  end
end
```


## Instead...

...use the `||=` (or equals) operator to store expensive computations in an instance variable.


```ruby
class OldTimeySweetShop
  def average_sweets_per_jar
    sweet_count / glass_jars.count
  end

  def sweet_count
    @sweet_count ||= glass_jars.sum do |jar|
      jar.count_each_sweet_by_hand
    end
  end
end

shop = OldTimeySweetShop.new
shop.sweet_count
#=> 4000003
shop.sweet_count
#=> 4000003 # this one will be super quick!
shop.average_sweets_per_jar
#=> 8000 # this uses the cached sweet_count
```


## Why?

In typical Rails applications, I've found this pattern to be most useful to optimize expensive database calls and to temporarily cache API requests to external services.

The succinctness of the `||=` operator means there is only a small impact on the readability of your code.


## Why not?

This `||=`-based technique can't be used if the result of the computation is `false` or `nil`, in that case you should use [the `defined?` method to memoize](/ruby/use-enhanced-memoization-for-false-nil-with-defined/).

A piece of code can be memoized _only if_ calling the code again would have the same output as replacing that function call with its return value.

If you're looking at method calls with parameters, you can create a memoized lookup table, but that's more complex than the examples in this article.

Memoizing results of repeated database queries isn't strictly necessary as Rails does its own caching at the SQL level.

### Beware Threads!

You should be careful when using memoization in a high-throughput, threaded Ruby environment. You probably are; `sidekiq` is threaded and many Ruby web servers are as well.

When your code is reaching _outside_ of the Ruby interpreter (e.g. reusable database connections, file handling, writing to a data store, manually creating background threads) it is possible to introduce race conditions if your code is called by multiple threads at the same time. However… you’re unlikely to be doing this in the course of day to day application, but it is a possible source of bugs. So be aware.

Hat tip to Ivo on this one, he's resolved [bugs in open source projects](https://github.com/DataDog/dd-trace-rb/pull/1329) that demonstrate this issue. You can see his recorded talk on [spotting unsafe ruby patterns](https://ivoanjo.me/blog/2018/10/13/spotting-unsafe-ruby-patterns/) which dives into the details.

