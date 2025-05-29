---
title: "Further Performance Testing Enumerable’s Loveliness"
description: "Benchmarking & code golfing"
layout: article
category: ruby
date: 2025-05-29 08:00
image:
  base: "2025/performance-testing-enumerables-loveliness"
  alt: "Race track"
  credit: "Nicolas Hoizey"
  source: "https://unsplash.com/photos/people-running-on-race-track-poa-Ycw1W8U"
---

Ok, I'll stop after this one, but I [said that before](/ruby/benchmarking-odd_sum). Plenty of fun nerd-sniping on this problem.

I was pointed at `Enumerable#partition` (by [Brandon](https://bsky.app/profile/baweaver.bsky.social/post/3lq42wj6efs2k), [Michael](https://chaos.social/@citizen428), [Piotr](https://bsky.app/profile/chastell.net/post/3lq5s3ummnc2i) & [Kasper](https://bsky.app/profile/kaspth.bsky.social/post/3lqa7ft5f5k2v)) which would avoid two of the four loops in the previously "best" solution.

I was also nudged to benchmark my initial "loops" solution by [Dave](https://ruby.social/@davetron5000/114576061212512715), because straightforward loops are often extremely well optimised at the language level.

So... here's all the benchmarks for that.

```ruby
require 'benchmark/ips'

n = 100
a = Array.new(n) { |i| rand(1_000_000) }
b = Array.new(n) { |i| rand(1_000_000) }

Benchmark.ips do |x|
  # Pre-filter by odd/even, then compute products
  x.report('odd & even') do
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
  x.report('loops') do
    results = []
    a.each do |x|
      b.each do |y|
        if ((x + y) % 2) == 1
          results << [x, y]
        end
      end
    end
    results.uniq
  end
  x.report('partition') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    (odd_as.product(even_bs) + odd_bs.product(even_as)).uniq
  end

  x.compare!
end
```

Here's the results:

```
Calculating -------------------------------------
          odd & even      1.347k (± 2.2%) i/s  (742.59 μs/i) -      6.850k in   5.089081s
     full product, +    785.253  (± 1.5%) i/s    (1.27 ms/i) -      3.952k in   5.034013s
   full product, sum    719.042  (± 2.1%) i/s    (1.39 ms/i) -      3.650k in   5.078324s
               loops    893.864  (± 1.3%) i/s    (1.12 ms/i) -      4.488k in   5.021755s
           partition      1.370k (± 1.8%) i/s  (729.79 μs/i) -      6.900k in   5.037264s

Comparison:
           partition:     1370.3 i/s
          odd & even:     1346.6 i/s - same-ish: difference falls within error
               loops:      893.9 i/s - 1.53x  slower
     full product, +:      785.3 i/s - 1.74x  slower
   full product, sum:      719.0 i/s - 1.91x  slower
```

Further improvements were suggested.

If we use a more apt method for [combining arrays](https://docs.ruby-lang.org/en/master/Array.html#class-Array-label-Methods+for+Combining), like [`|`](https://docs.ruby-lang.org/en/master/Array.html#method-i-7C) or [`union`](https://docs.ruby-lang.org/en/master/Array.html#method-i-union) we may see a performance improvement as we avoid the additional `uniq` loop through the final array of results.

```ruby
require 'benchmark/ips'

n = 100
a = Array.new(n) { |i| rand(1_000_000) }
b = Array.new(n) { |i| rand(1_000_000) }

Benchmark.ips do |x|
  x.report('odd & even') do
    (a.select(&:odd?).product(b.select(&:even?)) +
      b.select(&:odd?).product(a.select(&:even?)))
    .uniq
  end
  x.report('odd & even union') do
    a.select(&:odd?).product(b.select(&:even?)).union(
        b.select(&:odd?).product(a.select(&:even?)))
  end
  x.report('odd & even |') do
    a.select(&:odd?).product(b.select(&:even?)) |
      b.select(&:odd?).product(a.select(&:even?))
  end
  x.report('loops') do
    results = []
    a.each do |x|
      b.each do |y|
        if ((x + y) % 2) == 1
          results << [x, y]
        end
      end
    end
    results.uniq
  end
  x.report('loops |') do
    results = []
    a.each do |x|
      b.each do |y|
        if ((x + y) % 2) == 1
          results | [x, y]
        end
      end
    end
    results
  end
  x.report('partition') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    (odd_as.product(even_bs) + odd_bs.product(even_as)).uniq
  end
  x.report('partition union') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    odd_as.product(even_bs).union(odd_bs.product(even_as))
  end
  x.report('partition |') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    odd_as.product(even_bs) | odd_bs.product(even_as)
  end

  x.compare!
end
```

The results are pretty much a wash for the partition and odd & even cases.

```
Calculating -------------------------------------
          odd & even      1.375k (± 0.4%) i/s  (727.08 μs/i) -      6.987k in   5.080142s
    odd & even union      1.334k (± 0.4%) i/s  (749.77 μs/i) -      6.700k in   5.023541s
        odd & even |      1.339k (± 0.4%) i/s  (746.81 μs/i) -      6.700k in   5.003743s
               loops    896.130 (± 0.9%) i/s    (1.12 ms/i) -      4.500k in   5.022004s
             loops |      1.416k (± 1.1%) i/s  (706.43 μs/i) -      7.100k in   5.016274s
           partition      1.378k (± 0.8%) i/s  (725.47 μs/i) -      6.900k in   5.006093s
     partition union      1.349k (± 0.6%) i/s  (741.43 μs/i) -      6.834k in   5.067094s
         partition |      1.346k (± 0.4%) i/s  (742.74 μs/i) -      6.834k in   5.075995s

Comparison:
             loops |:     1415.6 i/s
           partition:     1378.4 i/s - 1.03x  slower
          odd & even:     1375.4 i/s - 1.03x  slower
     partition union:     1348.7 i/s - 1.05x  slower
         partition |:     1346.4 i/s - 1.05x  slower
        odd & even |:     1339.0 i/s - 1.06x  slower
    odd & even union:     1333.7 i/s - 1.06x  slower
               loops:      896.1 i/s - 1.58x  slower
```

However, the performance of the "straightforward" loop solution is still significantly the worst, but when using the`|` operator in the depths of the loop, it leaps to becoming marginally better performing than all the other implementations.

One last thing. Ruby has a [lazy evaluation](https://docs.ruby-lang.org/en/master/Enumerator/Lazy.html) feature which can be used to avoid overheads of creating intermediate arrays in large datasets, but it's only available on certain methods on `Enumerable`.

One of those rewritten methods is `uniq`, does making the uniqueness loop a "lazy" enumerator affect performance? You can also use `lazy` with `each` in the "looping" example.

How do these new additions to the benchmark fare?

```ruby
require 'benchmark/ips'

n = 100
a = Array.new(n) { |i| rand(1_000_000) }
b = Array.new(n) { |i| rand(1_000_000) }

Benchmark.ips do |x|
  x.report('odd & even') do
    (a.select(&:odd?).product(b.select(&:even?)) +
      b.select(&:odd?).product(a.select(&:even?)))
    .uniq
  end
  x.report('odd & even lazy') do
    (a.select(&:odd?).product(b.select(&:even?)) +
      b.select(&:odd?).product(a.select(&:even?)))
    .lazy.uniq
  end
  x.report('loops') do
    results = []
    a.each do |x|
      b.each do |y|
        if ((x + y) % 2) == 1
          results << [x, y]
        end
      end
    end
    results.uniq
  end
  x.report('loops |') do
    results = []
    a.each do |x|
      b.each do |y|
        if ((x + y) % 2) == 1
          results | [x, y]
        end
      end
    end
    results
  end
  x.report('loops | lazy') do
    results = []
    a.lazy.each do |x|
      b.lazy.each do |y|
        if ((x + y) % 2) == 1
          results | [x, y]
        end
      end
    end
    results
  end
  x.report('partition') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    (odd_as.product(even_bs) + odd_bs.product(even_as)).uniq
  end
  x.report('partition lazy') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    (odd_as.product(even_bs) + odd_bs.product(even_as)).lazy.uniq
  end
  x.report('partition |') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    odd_as.product(even_bs) | odd_bs.product(even_as)
  end

  x.compare!
end
```

It _looks like_ the `lazy` version of `uniq` is a lot faster than the non-lazy versions, or the improved "loops with `|`" example, according to this test.

```
Calculating -------------------------------------
          odd & even      1.351k (± 2.5%) i/s  (740.37 μs/i) -      6.834k in   5.063314s
     odd & even lazy      6.145k (± 1.1%) i/s  (162.74 μs/i) -     31.263k in   5.088472s
               loops    917.432 (± 0.7%) i/s    (1.09 ms/i) -      4.641k in   5.058882s
             loops |      1.481k (± 2.7%) i/s  (675.29 μs/i) -      7.446k in   5.032326s
        loops | lazy      1.466k (± 0.3%) i/s  (682.27 μs/i) -      7.436k in   5.073396s
           partition      1.373k (± 0.5%) i/s  (728.15 μs/i) -      6.936k in   5.050569s
      partition lazy      5.224k (± 1.0%) i/s  (191.41 μs/i) -     26.180k in   5.011751s
         partition |      1.339k (± 0.7%) i/s  (746.74 μs/i) -      6.732k in   5.027289s

Comparison:
     odd & even lazy:     6144.7 i/s
      partition lazy:     5224.3 i/s - 1.18x  slower
             loops |:     1480.9 i/s - 4.15x  slower
        loops | lazy:     1465.7 i/s - 4.19x  slower
           partition:     1373.3 i/s - 4.47x  slower
          odd & even:     1350.7 i/s - 4.55x  slower
         partition |:     1339.2 i/s - 4.59x  slower
               loops:      917.4 i/s - 6.70x  slower
```

Is there some magic behind the scenes that makes the lazy version of `uniq` faster than the non-lazy version? **Sadly, no.** The lack of a performance difference between the lazy and non-lazy "loop" versions should be the clue here.

`uniq` processes the entire array immediately and returns a new array with duplicates removed. It has to examine every element to determine uniqueness.

`lazy.uniq` returns a `Enumerator::Lazy` that _doesn't do any work_ until you start consuming elements from it! In order for this to be a fair comparison the code would have to be:

```ruby
  # e.g.
  x.report('partition lazy') do
    odd_as, even_as = a.partition(&:odd?)
    odd_bs, even_bs = b.partition(&:odd?)
    (odd_as.product(even_bs) + odd_bs.product(even_as)).lazy.uniq.to_a
  end
```

The results bear this out:

```
Calculating -------------------------------------
             loops |      1.436k (± 2.6%) i/s  (696.42 μs/i) -      7.191k in   5.011518s
        loops | lazy      1.424k (± 1.4%) i/s  (702.40 μs/i) -      7.228k in   5.078029s
           partition      1.359k (± 1.7%) i/s  (735.93 μs/i) -      6.885k in   5.068374s
      partition lazy    814.193  (± 2.9%) i/s    (1.23 ms/i) -      4.116k in   5.060084s

Comparison:
             loops |:     1435.9 i/s
        loops | lazy:     1423.7 i/s - same-ish: difference falls within error
           partition:     1358.8 i/s - 1.06x  slower
      partition lazy:      814.2 i/s - 1.76x  slower
```

What have we learned from this wild goose chase of nerd-sniping?

1. It's ok to optimise for readability.
2. It's important to _accurately_ benchmark your code when you're trying to optimize.
3. Ruby is delightful.
4. I sometimes can't let go.
