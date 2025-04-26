---
title: "What’s the difference between Rails’s try and the safe navigation (&.) operator?"
description: "They aren't the same, so it's important to understand the difference"
layout: article
category: ruby
date: 2025-04-28 04:00
image:
  base: "2024/rails-try-vs-safe-navigation-operator"
  alt: "Wooden Scrabble pieces spelling SAFE"
  credit: "Clarissa Watson"
  source: "https://unsplash.com/photos/brown-and-black-letter-b-letter-2gzfzR13DOQ"
---

When working with objects in Ruby and Rails you often need to safely call a chain of methods without accidentally raising `NoMethodError`, if it's possible that any of the methods in the chain could return `nil`.

Rails provides the [`try` method](https://api.rubyonrails.org/classes/Object.html#method-i-try) as a core extension to `Object`, while Ruby (since 2.3) offers the safe navigation operator: an ampersand followed by a full stop (`&.`).

Understanding which to use, and what the subtle differences are between them, can lead to cleaner, more robust code.

## Instead of…

...using conditional checks or rescue blocks:

```ruby
def display_username(user)
  if user && user.profile && user.profile.name
    user.profile.name
  else
    "Anonymous"
  end
end

# Or (worse!)
def display_username(user)
  user.profile.name
rescue NoMethodError
  "Anonymous"
end
```

## Use…

...`try` or the safe navigation operator:

```ruby
# Using try
def display_username(user)
  user.try(:profile).try(:name) || "Anonymous"
end

# Using safe navigation operator
def display_username(user)
  user&.profile&.name || "Anonymous"
end

# They can even be used together!
def display_username(user)
  user.try(:profile)&.name || "Anonymous"
end
```

## Why?

Primarily, as you can see in the examples, these methods are used for clarity: the resulting code is terser while remaining readable.

## Why not?

There may be cases where you could chain _many_ methods together with either syntax. This is probably a sign you should consider refactoring your code.

## Which to use?

Both `try` and the safe navigation operator (`&.`) both provide ways to safely call methods on objects that might be `nil`. However, they have some key differences.

Rails’s `try` returns `nil` for non-existent methods whereas `&.` raises a `NoMethodError` for non-existent methods.

```ruby
# Given a User class with an email method

User.new&.email
#=> ""

User.new.try(:email)
#=> ""

User.new&.email_2
#=> NoMethodError: undefined method `email_2' for an instance of User

User.new.try(:email_2)
#=> nil
```

You could rephrase or understand this as `#try` returns `nil` for any method (existing or not) called on Ruby’s `NilClass` and `&.` returns `nil` when the receiver is `nil`.

If you want to call a method that might not exist and swallow any errors, you should use the more forgiving `#try`, if you want the 💥 of a `NoMethodError` for cases where the receiving object does not define the passed method, then choose `&.`.

The choice often depends on specific project conventions and error handling strategies. For example, if you’re using Rails, you might still want to use `&.` in most cases given its native Ruby support and neater syntax. It's important to understand the differences between the two methods and choose the one that best fits your use case.

There are likely performance differences between the two methods, but you should benchmark your own code to determine which is faster for your use case. They're both well optimized and well tested so it would need to be a particulally "hot" code path to see a measurable difference in application code.

### Syntax differences

When you pass arguments to `#try`, it passes them to the method you’re calling, e.g. `object.try(:method, arg1, arg2)`. In comparison `&.` uses regular (more attractive?) method call syntax: `object&.method(arg1, arg2)`. In addition to passing arguments, `#try` can also accept a block `object.try { |obj| obj.do_something }`, `&.` doesn't have this form.

There is also a `#try!` method that exists in Rails, which raises an exception for non-existent methods, offering a third variation.

## Fun Fact!

Matz refers to the safe navigation operator, `&.`, as "the lonely operator" because if you look at the characters—the ampersand next to the dot—it resembles a person sitting alone on the floor.
