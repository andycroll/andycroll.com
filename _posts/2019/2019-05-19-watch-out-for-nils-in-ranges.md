---
title: Watch Out For nil in Ranges
description: To Infinity and Beyond
layout: article
category: ruby
image:
  base: '2019/watch-out-for-nil-in-ranges'
  alt: 'Buzz Lightyear'
---

Ruby 2.6 enhanced the syntax for `Range` to allow for infinite values at either end, therefore allowing them to be "endless". The new syntax is described in the [Ruby documentation](https://ruby-doc.org/core-2.6.3/Range.html#class-Range-label-Endless+Ranges).

This is great for representing concepts such as date ranges between some date and one anytime the future, but this new “sugared” syntax changes existing behaviour.


## Ruby used to…

…raise an `ArgumentError` when a `nil` was passed into a range…

```ruby
end_of_range = nil
(1..end_of_range).map { |i| do_something(i) }
#=> ArgumentError (bad value for range)
```


## But now…

…beware that a `Range` ending in `nil` no longer throws an error, but represents an _endless_ range.

```ruby
end_of_range = nil
(1..end_of_range).map { |i| do_something(i) }
#=> infinite loop!
```


## Why be careful?

Ruby 2.5, and earlier, already had the ability to create endless ranges, but only by using special _explicit_ constants—such as `Float::INFINITY`.

Allowing `nil` to be considered a valid input to a range, in a language where the result of methods can often unexpectedly _be_ `nil`, definitely gives us another place to make obscure mistakes.


## Why not?

You don't really have a choice here—it’s a part of the language.

But, you can protect yourself by ensuring that you check any value you pass into a `Range`. It isn’t seen as “good practice” to scatter `nil` checks in your code, but Ruby has never been about purity in its approach to object-oriented programming.
