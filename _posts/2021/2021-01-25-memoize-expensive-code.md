---
title: "Memoize Expensive Code"
description: ""
layout: article
category: ruby
image:
  base: '2021/memoize-expensive-code'
  alt: "Red Floppy Disk"
  credit:  Fredy Jacob
  source: "https://unsplash.com/photos/t0SlmanfFcg"
---

Memoization is a performance optimization where the result of a slow or non-performant piece of code is stored and when the expensive code is called again, the stored value is returned.

It is a specific form of caching that is relatively elegant to read and implement in Ruby.


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

```ruby
class OldTimeySweetShop
  # leave the same

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
```


## Why?

Primarily this is a performance optimization. The first call of the method stores the result of an expensive operation in an instance variable that is then returned.

When the method is called again the stored instance value is used and the expensive calculation is avoided.

In typical Rails applications, I've found this patten to be most useful to optimize expensive database calls and to temporarily cache API requests to external services.


## Why not?

A piece of code can only be memoized _only if_ calling the code again would have the same output as replacing that function call with its return value.

If you're looking at method calls with parameters, you can create a memoized lookup table, but it's more complex than the examples in this article.

Memoizing results of repeated database queries isn't strictly necessary as Rails does it's own caching at the SQL level.
