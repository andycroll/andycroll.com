---
title: "Calculate the standard deviation of a Ruby array"
description: "A lesson in why we use native Ruby methods"
layout: article
category: ruby
image:
  base: '2020/calculate-a-mean-average-from-a-ruby-array'
  alt: "Black and White Texas Instruments calculator"
  credit:  Ray Reyes
  source: "https://unsplash.com/photos/3xwrg7Vv6Ts"

---

Standard deviation is a measure of the amount of variance within a group of values. A high value indicates a wide spread of values around the mean, whereas a low value indicates tight clustering of values.

The calculation is used to understand and give context to the mean value of a series of data, [wikipedia has some good examples of real-world applications](https://en.wikipedia.org/wiki/Standard_deviation#Application_examples).

Ruby doesn’t provide a native method to generate the standard deviation of an array of integers. Its built-in [`Math`](https://ruby-doc.org/core-3.0.0/Math.html) library focuses on trigonometry and logarithmic calculations. Given there is no built-in way [to calculate the mean of an array in Ruby](/ruby/calculate-a-mean-average-from-a-ruby-array) there’s equally no way to calculate the standard deviation.


## Ensure you use...

...`Array#sum` when calculating both the mean and the standard deviation from an array of integers:

```ruby
a = [1, 2, 3, 4, 5, 6, 7, 8]

mean = a.sum(0.0) / a.size
#=> 4.5
sum = a.sum(0.0) { |element| (element - mean) ** 2 }
#=> 42.0
variance = sum / (a.size - 1)
#=> 6.0
standard_deviation = Math.sqrt(variance)
#=> 2.449489742783178
```


## Why?

Using [the `#sum` method from `Array`](https://ruby-doc.org/core-3.0.0/Array.html#method-i-sum) is many, many times faster than using the alternative, `inject`.

The `#sum` method was only added to `Array` in Ruby 2.4, which is why you might see alternative implementations in other places on the Internet.

I compared the performance of Ruby-native vs. implementing the algorithms yourself when I wrote about [calculating the mean](/ruby/calculate-a-mean-average-from-a-ruby-array) and the same principles apply: that native implementations (in C) are much faster.


## Anything else?

In all honesty, if you’re doing a lot of statistical number-crunching work you probably want to reach a little closer to “the metal”.

A version of the standard deviation calculation done in Ruby is much slower than if it were done natively in C. This 'lower-level' support is why running `sum` is much faster than running `inject` in the above example, because Ruby’s `sum` method is implemented in C.

If you're doing a lot of this sort of calculation or in a situation performance is key you might want to look at the [`enumerable-statistics`](https://github.com/mrkn/enumerable-statistics) gem. It has natively implemented (in C, called from Ruby) versions of several statistical summary methods mixed in directly to Ruby's `Array` and `Enumerable` classes.
