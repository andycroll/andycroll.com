---
title: "Enumerable’s loveliness"
description: "A Ruby solution to Cassidy William's oddSum Interview Question"
layout: article
category: ruby
date: 2025-05-26 09:00
image:
  base: "2025/enumerables-loveliness"
  alt: "Child playing with numbers"
  credit: "Anna Mysłowska-Kiczek"
  source: "https://unsplash.com/photos/a-child-is-playing-with-a-wooden-toy-s7nHwCnq3c8"
---

I'm often nerd-sniped by the "Interview Question of the week" that [Cassidy Williams](https://cassidoo.co/) includes in her weekly newsletter. Typically it's when I see a solution that show's off Ruby's cornucopia of `Enumerable` methods. This [week's `odd_sum` was catnip](https://buttondown.com/cassidoo/archive/false-expectations-take-away-joy-sandra-bullock/).

> **This week's question:**
>
> Given two arrays, return all pairs (where each number is in each array) whose sum is an odd number.

```js
oddSum([9, 14, 6, 2, 11], [8, 4, 7, 20]);
// > [9, 20], [14, 7], [11, 8]

oddSum([2, 4, 6, 8], [10, 12, 14]) > null;
// (or whatever falsy value you prefer)
```

---

The most brute-force "generic language" solution is to do a nested loop over the arrays and check the sum of each pair for an odd result.

```ruby
def odd_sum(a, b)
  results = []
  a.each do |x|
    b.each do |y|
      if ((x + y) % 2) == 1
        results << [x, y]
      end
    end
  end
  results
end
```

However, we're smarter than that. And Ruby is lovely. Knowing (from elementary arithmatic) that _only_ the sum of an odd and an even number is odd we can base our solution on the properties of the elements of the arrays and avoid doing the mathematical check.

Initially I'd hoped I could _one-liner_ it using the combination of `#select`, `#product`, `#odd?` and `#even?` methods on the two passed arrays.

```ruby
def odd_sum(a, b)
  a.select(&:odd?).product(b.select(&:even?)) +
    b.select(&:odd?).product(a.select(&:even?))
end
```

After I posted this, [Xavier](https://bsky.app/profile/fxn.bsky.social/post/3lq34jgmgo22f) & [Alex](https://ruby.social/@pointlessone@status.pointless.one/114574888052999616) both pointed out that I could indeed do this in a one-liner, I'd fallen for my own trap of _not_ doing the mathematical check.

```ruby
def odd_sum(a, b)
  a.product(b).select { (_1 + _2).odd? }
end
```

In both cases, the "no results" case needs to be `false`-y and an empty array in Ruby is `true`-thy.

```ruby
> !![]
#=> true
```

The complete solution includes the use of Active Support's [underused `#presence` method](/ruby/use-the-presence-method), which I've previously suggested is a lovely little enhancement within Rails applications. Plus I added a uniqueness check in there as well as that seemed to be a reasonable improvement.

```ruby
require "active_support"

def odd_sum(a, b)
  (a.select(&:odd?).product(b.select(&:even?)) +
    b.select(&:odd?).product(a.select(&:even?)))
    .uniq
    .presence
end

# or
def odd_sum(a, b)
  a.product(b)
    .select { (_1 + _2).odd? }
    .uniq
    .presence
end
```

There's likely performance optimizations we could execute here but that'd reduce the readability of the code. _If_ this was a hot code path—in a live application on massive datasets—it'd be worth benchmarking for improvements. NB: [I did some benchmarking](/ruby/cassiecodes-odd_sum-programming-exercise-performance-test)!

What's lovely from a Ruby perspective is the expression of the underlying mathematical concept that underpins the solution and reads almost like English: "odd from a with even from b, plus odd from b with even from a".

Another example of Ruby's delightful, readable, syntax.
