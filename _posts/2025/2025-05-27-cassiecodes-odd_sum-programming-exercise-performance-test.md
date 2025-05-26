---
title: "Performance Testing Enumerable’s Loveliness"
description: "Benchmarking & code golfing"
layout: article
category: ruby
date: 2025-05-27 09:00
image:
  base: "2025/performance-testing-enumerables-loveliness"
  alt: "Race track"
  credit: "Nicolas Hoizey"
  source: "https://unsplash.com/photos/people-running-on-race-track-poa-Ycw1W8U"
---

After sharing my [solution to Cassidy Williams' oddSum challenge](/ruby/cassiecodes-odd_sum-programming-exercise), [Xavier](https://bsky.app/profile/fxn.bsky.social/post/3lq34jgmgo22f) & [Alex](https://ruby.social/@pointlessone@status.pointless.one/114574888052999616) suggested a simpler approach on social media. This got me curious: does avoiding the mathematical check actually improve performance?

So I decided to benchmark the solutions to find out.

```ruby
require 'benchmark/ips'

n = 10
a = Array.new(n) { |i| rand(1_000_000) }
b = Array.new(n) { |i| rand(1_000_000) }

Benchmark.ips do |x|
  # Mine: pre-filter by odd/even, then compute products
  x.report('odd & even check') do
    (a.select(&:odd?).product(b.select(&:even?)) +
      b.select(&:odd?).product(a.select(&:even?)))
    .uniq
  end
  # Alternatives: compute all products, then filter by sum
  x.report('full product, +') do
    a.product(b).select { (_1 + _2).odd? }.uniq
  end
  x.report('full product, sum') do
    a.product(b).select { _1.sum.odd? }.uniq
  end

  x.compare!
end
```

In the testing script I set a variable (`n`) for the size of the generated arrays. I presumed that for small arrays there'd be very little difference it would be more noticeable as the arrays grew larger. Intuitively, I'd expect the performance to be worse when using the full product approach, as the memory allocation of the intermediate array would be much larger.

Here's the results when `n = 10`:

```
Warming up --------------------------------------
    odd & even check     9.686k i/100ms
     full product, +     7.030k i/100ms
   full product, sum     6.911k i/100ms
Calculating -------------------------------------
    odd & even check     97.138k (± 0.7%) i/s   (10.29 μs/i) -    493.986k in   5.085694s
     full product, +     74.138k (± 1.8%) i/s   (13.49 μs/i) -    372.590k in   5.027459s
   full product, sum     69.031k (± 0.9%) i/s   (14.49 μs/i) -    345.550k in   5.006096s

Comparison:
    odd & even check:    97137.7 i/s
     full product, +:    74137.7 i/s - 1.31x  slower
   full product, sum:    69031.3 i/s - 1.41x  slower
```

A surprising difference in comparative performance, given the small size of the array, but the individual runtimes are very small; in the microseconds.

And for `n = 1_000`:

```
Warming up --------------------------------------
    odd & even check     1.000 i/100ms
     full product, +     1.000 i/100ms
   full product, sum     1.000 i/100ms
Calculating -------------------------------------
    odd & even check     12.568 (± 8.0%) i/s   (79.57 ms/i) -     63.000 in   5.023134s
     full product, +      6.891 (± 0.0%) i/s  (145.12 ms/i) -     35.000 in   5.091415s
   full product, sum      6.369 (± 0.0%) i/s  (157.00 ms/i) -     32.000 in   5.029184s

Comparison:
    odd & even check:       12.6 i/s
     full product, +:        6.9 i/s - 1.82x  slower
   full product, sum:        6.4 i/s - 1.97x  slower
```

And for `n = 10_000`:

```
Warming up --------------------------------------
    odd & even check     1.000 i/100ms
     full product, +     1.000 i/100ms
   full product, sum     1.000 i/100ms
Calculating -------------------------------------
    odd & even check      0.054 (± 0.0%) i/s    (18.57 s/i) -      1.000 in  18.574282s
     full product, +      0.021 (± 0.0%) i/s    (46.66 s/i) -      1.000 in  46.663944s
   full product, sum      0.022 (± 0.0%) i/s    (45.83 s/i) -      1.000 in  45.833142s

Comparison:
    odd & even check:        0.1 i/s
   full product, sum:        0.0 i/s - 2.47x  slower
     full product, +:        0.0 i/s - 2.51x  slower
```

The main surprise, which I didn't initially consider, is how quickly the performance degrades with any of the approaches as the array sizes increase.

It makes sense, as that's a factor of O(`n`²) (or near enough) in all solutions. Thousand element arrays mean one million pairs to evaluate. Whereas ten thousand element arrays is one hundred million pairs: a 100x increase! The use of `.product` ends up creating large intermediate arrays which increase memory usage.

In reality, for small arrays—as suggested in the original question—the performance difference is negligible, so picking the most readable solution is the most important decision. As the arrays get beyond the thousands of elements, were we to execute this task in a typical web request, none of the solutions are going to scale well.

For truly large datasets we might consider streaming, lazy evaluation or parallelization, but that's outside the scope of _this_ [code golfing](https://en.wikipedia.org/wiki/Code_golf) exercise.
