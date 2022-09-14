---
layout: article
title: Use before? and after? Methods When Comparing Dates and Times in Rails
description: I can’t remember which is greater than or less than either.
category: ruby
image:
  base: 2022/use-before-and-after-methods-when-comparing-dates-and-times-in-rails
  alt: Clocks piled on top of each other
  source: https://unsplash.com/photos/FlHdnPO6dlw
  credit: Jon Tyson
---

Active Support contains many additions to the basic classes that form the standard libraries of Ruby. There are extensions to `String`, `Hash`, `Array` and even `Date` and `Time`.

If you’ve been working inside Rails you might not realise that these are Rails-isms rather than Ruby-isms.

Some folks dislike these ”superfluous” additions. Some of these additions end up back inside the Ruby standard library itself. _Some_ of these methods help me not make mistakes when comparing times and dates.


## Instead of...

...comparing dates and times with greater than or less than operators:

```ruby
Date.new(1979, 9, 12) > Time.zone.now
#=> false

10.minutes_ago < 5.minutes.from_now
#=> true
```


## Use...

...`before?` and `after?`.

```ruby
Date.new(1979, 9, 12).after?(Time.zone.now)
#=> false

10.minutes_ago.before?(5.minutes.from_now)
#=> true
```


## Why?

This is a personal stylistic choice. I find the readability of the logic to be hugely improved when using the `before?` and `after?` methods. This helps me reason about the code as I'm writing it and, more importantly, to understand my logic when I come back to it months from now.



## Why not?

Maybe you never get it wrong when you compare date and time objects. I do. A lot.

