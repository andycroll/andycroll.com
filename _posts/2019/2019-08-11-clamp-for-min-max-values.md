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

In [last week’s article](/ruby/consider-value-objects), I was constraining an integer to a minimum and maximum value. As of Ruby 2.4 there's a nice method for that: `#clamp`. The [documentation for the method is in the Comparable module](http://ruby-doc.org/core-2.6.3/Comparable.html#method-i-clamp).


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

...Ruby’s .

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

This is the exact use case for the problem I was trying to solve.


## Why not?

There’s no reason not to. Maybe you like the look of confusing square brackets?

## Thanks

My appreciation to [Justin](https://twitter.com/jerhinesmith) for pointing out my pre-2.4 Ruby.
