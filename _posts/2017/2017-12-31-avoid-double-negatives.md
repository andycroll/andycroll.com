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

Ruby has a bunch of delightful syntactic sugar. One example of this is `unless`, which you can use in place of an `if` with a negative.

However given the flexibility of Ruby's syntax it is easy to make code harder to understand than it needs to be.

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

Ruby’s conditional syntax is ‘truthy’. In Ruby’s case that means `nil` is equivalent to `false`. There is no need to do a negated `#nil?` check on an object as it is redundant as shown in the first two examples.

The syntax of `!!` in the third example converts a value to boolean, but it is unnecessary and likely obscures your intention. If you _really_ want to do a `nil` check, you should use `#nil?` instead.

You should definitely avoid using an `else` block with an `unless`: the `else` block is a double negative of the condition. Instead, switch the `unless` for an logically equivalent `if` and swap the code in the successful conditional block for the code in the `else` block. This might require some refactoring to the condition to make the resulting code easy to understand.

It is also _much_ harder to reason when using an `unless` conditional with any boolean algebra (`&&` or `||`). It is an easy way to confuse yourself! The conditional `unless one && two` is the same code as `if !one || !two`. In this case the complex `if` condition is an opportunity to refactor the conditional into a well named method so it can be better understood.


## Why not?

I’m definitely not saying don't use `unless`, but it's important to remember it is _sugar_ and thus it is important only to use it where it makes the resulting code clearer.
