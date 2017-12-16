---
title: 'Avoid Double Negatives'
description: 'if unless else end'
layout: article
category: ruby
image:
  base: '2017/avoid-double-negatives'
  alt: 'Two directions sign'
  source: 'https://unsplash.com/photos/lPQIndZz8Mo'
  credit: 'Pablo Garcia Saldaña'
---

One of Ruby’s strengths is it’s delightful built-in syntactic sugar. One example of this is `unless`, which you can use in place of using `if` combined with a negative statement.

However, given the flexibility of Ruby's syntax, it is easy to make code harder to understand than it needs to be.

## Instead of…

...overcomplicating your conditionals.

```ruby
# Example 1
unless something.nil?
  # do something
end

# Example 2
if !something.nil?
  # do something
end

# Example 3
if !!something
  # do something
end
```


## Use…

```ruby
# Instead of Examples 1,2 & 3
if something
  # do something
end
```


## But why?

Ruby’s conditional syntax is ‘truthy’, meaning `nil` is equivalent to `false`. Therefore a negated `#nil?` check on an object is redundant.

The syntax of `!!` is two consecutive boolean ‘not’ operators, if takes any value and converts it into `true` or `false`. However, given Ruby's ‘truthy’ conditionals it is unnecessary and adds redundant code.

You should definitely avoid using `else` block with an `unless`. This structure is hard to reason about because the `else` block acts as a double negative of the condition. Instead, replace the `unless` for an logically equivalent `if` and swap the code in the two branches of the conditional.

It is also _much_ harder to reason when using an `unless` conditional with any boolean algebra (`&&` or `||`). It is an easy way to confuse yourself! The conditional `unless one && two` is equivalent to `if !one || !two`. Although the logic looks messier I find the positive version easier to reason about.

A complex `if` condition might well be an opportunity to extract the conditional into a well-named method so it can be better understood.


## Why not?

I’m definitely not saying don't use `unless`, but it's important to remember it is _sugar_ and thus it is important only to use it where it makes the resulting code clearer.
