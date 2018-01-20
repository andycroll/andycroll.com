---
title: 'Enumerable avoids using temporary variables when looping'
description: 'Idiomatic Ruby is in the looping'
layout: article
category: ruby
image:
  base: '2018/enumerable-avoids-using-temporary-variables'
  alt: 'Fruit loops'
  source: 'https://unsplash.com/photos/BumOnw4oEZo'
  credit: 'David Streit'
---

Some of my favourite Ruby features are to be found in the Enumerable module. You can read more in the [Ruby documentation](http://ruby-doc.org/core-2.5.0/Enumerable.html).

A class representing a collection, such as Array, Set or Hash, has the methods and features of Enumerable included. `Enumerable` contains methods to allow you to loop through the members of that group and 'do stuff' based on each member of the collection.


## Instead of…

...using a C-style loop with a temporary variable. Which would be fine in many other languages.

```ruby
total = 0
[1, 3, 5, 7].each do |num|
  total += num
end
total
```


## Use…

...your deep love of one of Ruby’s `Enumerable` module, and implement using `inject`.

```ruby
[1, 3, 5, 7].inject(0) do |num, result|
  result += num
end
```


## Or better...

...remember, in this case, there’s a convenient `sum` method in `Enumerable` too.

```ruby
[1, 3, 5, 7].sum
```


## But why?

The longer I’ve used Ruby the more joy I find in the elegance enabled by its `Enumerable` methods. Using these constructions lead you write _idiomatic_ Ruby, which is a smart sounding way of saying you’re writing Ruby in a Ruby-ish manner.

In larger loops, there are benefits to memory usage and speed to using the built-in Enumerable methods which are written into the language.

If you ever see the "temporary variable set up" at the beginning of a loop there's most likely an opportunity to express yourself more concisely with an Enumerable method.


## Why not?

Methods like `inject` might seem confusing and be unfamiliar to newer rubyists. They are a fundamental benefit of using Ruby, so you might as well dive in.
