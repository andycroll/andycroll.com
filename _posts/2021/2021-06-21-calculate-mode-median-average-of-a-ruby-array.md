---
title: "Calculate the mode & median averages of a Ruby array"
description: "An average isn't just a mean average."
layout: article
category: ruby
image:
  base: '2020/calculate-a-mean-average-from-a-ruby-array'
  alt: "Black and White Texas Instruments calculator"
  credit:  Ray Reyes
  source: "https://unsplash.com/photos/3xwrg7Vv6Ts"

---

I've previously disscussed a way [to calculate the mean of an array in Ruby](/ruby/calculate-a-mean-average-from-a-ruby-array). But there are two other averages that you might see, less commonly used, but still useful.


## Calculate a median...

```ruby
a = [1, 3, 2, 4, 6, 5, 7, 8]

sorted = a.sort # required
#=> [1, 2, 3, 4, 5, 6, 7, 8]
midpoint = a.length / 2 # integer division
#=> 4
if a.length.even?
  # median is mean of two values around the midpoint
  sorted[midpoint-1, 2].sum / 2.0
else
  sorted[midpoint]
end
#=> 4.5
```


## Calculate a mode...

...using `Array#tally` then sorting:

```ruby
a = [1, 3, 3, 4, 6, 5, 7, 8]

tallied = a.tally
#=> {1=>1, 3=>2, 4=>1, 6=>1, 5=>1, 7=>1, 8=>1}
top_pair = tallied.sort_by { |_,v| v }.last(2)
#=> [[8, 1], [3, 2]]
if top_pair.size == 1
  top_pair[0][0] # only one element, it is the mode
elsif top_pair[0][1] == top_pair[1][1]
  nil # if count is same, no mode.
else
  top_pair[1][0]
end
#=> 3
```


## Why?

The `#tally` method was added to `Enumerable` in Ruby 2.7 so you might see implementations that use `inject` which will perform worse.

I compared the performance of using native Ruby methods versus your own implementations when I wrote about [calculating the mean](/ruby/calculate-a-mean-average-from-a-ruby-array).


## Anything else?

It's no doubt a good idea to further encapsulate these calulations into methods.

However you're doing a lot of this sort of calculation or in a situation performance is important you should look at the [`enumerable-statistics`](https://github.com/mrkn/enumerable-statistics) gem. It has natively implemented (in C, that are called from Ruby) versions of several statistical summary methods mixed in directly to `Array`s and `Enumerable`s, and thus is much faster than any version of the algorithm in Ruby.
