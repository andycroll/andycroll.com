---
title: "Find the Last Matching Element with rfind"
description: "Using Array#rfind to efficiently find elements the last of a thing"
layout: article
category: ruby
date: 2026-01-12 09:00
image:
  base: "2026/find-the-last-matching-element-with-rfind"
  alt: "Magnifying glass on white table"
  credit: "Markus Winkler"
  source: "https://unsplash.com/photos/magnifying-glass-on-white-table-afW1hht0NSs"
---

Ruby 4.0 landed during Christmas 2025 with a bunch of new features. One [small but useful addition](https://bugs.ruby-lang.org/issues/21678) is [`Array#rfind`](https://docs.ruby-lang.org/en/4.0/Array.html#method-i-rfind), which finds the last element in an array that matches a condition.

## Instead of…

...reversing the array or using `reverse_each` to find from the end:

```ruby
numbers = [2, 2, 3, 4, 6, 7, 8]

numbers.reverse.find(&:odd?)
#=> 7

# or
numbers.reverse_each.find(&:even?)
#=> 8
```

## Use…

...Ruby 4.0's `rfind` method:

```ruby
numbers = [2, 2, 3, 4, 6, 7, 8]

numbers.rfind(&:odd?)
#=> 7

# with a block
numbers.rfind { it.even? }
#=> 8
```


## Why?

The `rfind` method iterates backwards from the last element, returning the first element that matches the given condition. It's the **r**everse of `find`, which starts from the beginning.

This is more efficient than `reverse.find` or `reverse_each.find` because it doesn't create an intermediate reversed array or enumerator in memory. For large arrays, this _can_ make a noticeable difference.

You might wonder why this was added to `Array` specifically rather than `Enumerable`. The `Enumerable` module relies on the `#each` method, which only works in the forward direction. The only way to scan backwards generically would be to convert to an array first, defeating the purpose. However, arrays can be traversed in either direction efficiently by the nature of their implementation in the Ruby VM.


## Why not?

If you're not yet on Ruby 4.0, you'll need to stick with `reverse_each.find` for now. It's not a dramatic difference, but `rfind` is cleaner and more intentional.

For very small arrays, the performance difference is negligible, so the main benefit is readability—your intent is clearer when you use `rfind`.


## Did you know?

In the same changeset, [Kevin Newton](https://kddnewton.com) also added a specific implementation of `Array#find` (and its alias `#detect`) rather than relying on the `Enumerable` version. This is a performance improvement for arrays.
