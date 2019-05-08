---
title: Watch Out For nil in Ranges
description: To Infinity and Beyond
layout: article
category: ruby
image:
  base: '2019/watch-out-for-nil-in-ranges'
  alt: 'Buzz Lightyear'
---

Ruby 2.6 enhanced the syntax for ranges to allow for infinite values at either end. The new syntax is described in the [Ruby documentation for `Range`](http://ruby-doc.org/core-2.6.3/Range.html#class-Range-label-Endless+Ranges).

This is great for representing concepts such as date ranges between some date and one anytime the future, but this new “sugared” syntax changes existing behaviour.


## Instead of…

…raising an `ArgumentError` when a `nil` is passed into a range…

```ruby
end_of_range = nil
(1..end_of_range).map { |i| do_something(i) }
#=> ArgumentError (bad value for range)
```


## Beware…

…that a `Range` ending in `nil` no longer throws an error, but represents an _endless_ range.

```ruby
end_of_range = nil
(1..end_of_range).map { |i| do_something(i) }
#=> infinite loop!
```


## But why?

Ruby 2.5, and earlier, already had the ability to create endless ranges, but only by using special constants—such as `Float::INFINITY` in the `Range`s.

But allowing `nil` to represent, in a language where the result of methods can often _be_ `nil` definitely gaves us another place to make mistakes.


## Why not?

You don't really have a choice here, it’s a part of the language.

But, you can protect yourself by ensuring that you check any value you pass into a `Range`. It isn’t “good practice” to scatter `nil` checks in your code, but Ruby has never been about purity in its approach to object-oriented programming.
