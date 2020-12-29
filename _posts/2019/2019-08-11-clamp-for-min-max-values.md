---
title: "Clamp for min/max values"
description: "Constrain to a range of numbers"
layout: article
category: ruby
image:
  base: '2019/clamp-for-min-max-values'
  alt: 'Clamp'
  credit: Matt Artz
  source: "https://unsplash.com/photos/7_zxKAWCDQI"

---

In [my article on value objects](/ruby/consider-value-objects), the example involved constraining an integer to a minimum and maximum value in the `#initialize` method. As of Ruby 2.4, there's a handy method for that: `#clamp`. The [documentation for the method](https://ruby-doc.org/core-2.6.3/Comparable.html#method-i-clamp) is in the Comparable module.


## Instead of...

...using `Array#min` and `Array#max` to constrain a value within a range:

```ruby
value = 1000
[[0, value].max], 255].min
#=> 255

value = -100
[[0, value].max], 255].min
#=> 0
```

## Use...

...Ruby’s `#clamp` method.

```ruby
value = 1000
value.clamp(0, 255)
#=> 255

value = -100
value.clamp(0, 255)
#=> 0
```


## Why?

The standard library is deliberately expansive and elegant.

This is the exact use case for the problem I was trying to solve, so why use more verbose syntax?


## Why not?

There’s no reason not to. Maybe you like the look of confusing square brackets?

## Thanks

My appreciation to [Justin](https://twitter.com/jerhinesmith) for pointing out my pre-2.4 Ruby.
