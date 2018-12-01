---
title: 'Be sparing when using unless'
description: 'Gimme some sugar, but not too much'
layout: article
category: ruby
image:
  base: '2018/be-sparing-when-using-unless'
  alt: 'Two directions sign'
  source: 'https://unsplash.com/photos/lPQIndZz8Mo'
  credit: 'Pablo Garcia Saldaña'
---

One of Ruby’s strengths is its delightful, built-in syntactic sugar. One example of this is the keyword `unless`, which you can use in place of using `if` combined with a negative statement.

However, given the flexibility of Ruby's syntax, it is easy to make code harder to understand than it needs to be.

## Instead of…

…using `unless` in ways that makes your brain hurt.

```ruby
# Example 1
unless something?
  # do something
else
  # do other thing
end

# Example 2
unless something? || another_thing?
  # do something
end
```


## Use…

…`if` where it makes the code clearer.

```ruby
# Example 1
if !something?
  # do other thing
else
  # do something
end

# Example 2
if !something? && !another_thing?
  # do something
end
```


## But why?

Avoid using an `else` block with an `unless`. This structure is hard to reason about because the `else` block is a double negative: it is "not not" the specified condition. Instead, replace the `unless` with an `if`, taking care to refactor the condition statement as needed, then swap around the blocks of code in the main and `else` branches.

It is _much_ harder to understand the code when using an `unless` conditional with boolean algebra (`&&` or `||`). It is an easy way to confuse yourself! The conditional `unless one && two` is equivalent to `if !one || !two`. Although the logic looks messier the positive version is easier to reason about.

A complex `if` condition might well be an opportunity to extract the conditional into a well-named method so it can be more easily understood.


## Why not?

I’m definitely not saying don't use `unless`, but it's important to remember it is _sugar_ and thus important only to use it where it makes the resulting code clearer.
