---
title: "Calculate a mean average from a Ruby array"
description: "A lesson in why we use native Ruby methods"
layout: article
category: ruby
image:
  base: '2020/calculate-a-mean-average-from-a-ruby-array'
  alt: "Black and White Texas Instruments calculator"
  credit:  Ray Reyes
  source: "https://unsplash.com/photos/3xwrg7Vv6Ts"

---

Ruby doesn’t provide a native method to generate an average (mean) value from an array of integers. Its built-in [math](https://ruby-doc.org/core-2.7.0/Math.html) library focuses on more complex calculations and there's no built-in `#average` or `#mean` method on `Array`.

This leaves us free to create our own implementation, bringing the opportunity to shoot ourselves in the foot.


## Ensure you use...

...`Array#sum` when calculating the mean average from an array of integers:

```ruby
a = [1, 2, 3, 4, 5, 6, 7, 8]

a.sum(0.0) / a.size
#=> 4.5
```


## Why?

This approach using [the `#sum` method from `Array`](https://ruby-doc.org/core-2.7.0/Array.html#method-i-sum) is many, many times faster than using an alternative approach using `inject`.

The `#sum` method was added to `Array` in Ruby 2.4, which is why you might see alternative implementations in other places on the Internet.

In order to compare the performance of the different implementations we can use the `benchmark-ips` gem.

```ruby
require "benchmark/ips"

# Generate a 1,000 element array
a = Array.new(1000) { |_| rand(1000) }

Benchmark.ips do |x|
  x.report("sum(0.0) / size") do
    a.sum(0.0) / a.size
  end
  x.report('inject(0.0) / size') do
    a.inject(0.0) { |result, i| result + i } / a.size
  end
  x.compare!
end
```

The results (on my laptop) show a 50× speed improvement when using the native `#sum`. This method was built into the language to provide exactly this sort of performance improvement.

```
Calculating -------------------------------------
   sum(0.0) / size  680.425k (± 6.5%) i/s -  3.432M in 5.06s
inject(0.0) / size   13.513k (± 5.0%) i/s - 67.586k in 5.01s

Comparison:
   sum(0.0) / size: 680425.2 i/s
inject(0.0) / size:  13512.7 i/s - 50.35x  slower
```

Although there are variations of using `#sum` and then `#size` that perform similarly, the biggest performance win is choosing to use the native `#sum` method in the first place.

The benchmarking code for a wider variety of implementations:

```ruby
require "benchmark/ips"

# Generate a 1,000 element array
a = Array.new(1000) { |_| rand(1000) }

Benchmark.ips do |x|
  x.report("sum(0.0) / size") do
    a.sum(0.0) / a.size
  end
  x.report("sum.to_f / size") do
    a.sum.to_f / a.size
  end
  x.report("sum / size.to_f") do
    a.sum / a.size.to_f
  end
  x.report("sum.fdiv(size)") do
    a.sum.fdiv(a.size)
  end
  x.report('inject(0.0, :+) / size') do
    a.inject(0.0, :+) / a.size
  end
  x.report('inject(0.0) / size') do
    a.inject(0.0) { |result, i| result + i } / a.size
  end
  x.report('inject(0).to_f / size') do
    a.inject(0) { |result, i| result + i }.to_f / a.size
  end
  x.report('inject(0) / size.to_f') do
    a.inject(0) { |result, i| result + i } / a.size.to_f
  end
  x.report('inject(0).fdiv(size)') do
    a.inject(0) { |result, i| result + i }.fdiv(a.size)
  end
  x.compare!
end
```

...and the comparison results:

```
Comparison:
       sum(0.0) / size: 668222.4 i/s
       sum / size.to_f: 660291.4 i/s - same-ish
       sum.to_f / size: 655929.1 i/s - same-ish
        sum.fdiv(size): 621960.0 i/s - same-ish
inject(0.0, :+) / size:  30823.6 i/s - 21.68x slower
 inject(0) / size.to_f:  18740.7 i/s - 35.66x slower
 inject(0).to_f / size:  18320.1 i/s - 36.47x slower
  inject(0).fdiv(size):  18082.6 i/s - 36.95x slower
    inject(0.0) / size:  15264.0 i/s - 43.78x slower
```


## Anything else?

Rails’ Active Record does include an [`#average` method](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-average). It’s used to perform calculations on numerical columns in the database directly in SQL.

You’re probably best to use that if that is your specific use case, creating Active Record models and then iterating over them in ruby will nearly always be slower.
