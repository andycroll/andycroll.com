---
title: 'Rescue specific errors. Avoid rescuing StandardError. Don’t rescue Exception.'
description: 'Rescuing all the things is bad.'
layout: article
category: ruby
image:
  base: '2017/rescue-specific-errors-avoid-standarderror-do-not-rescue-exception'
  alt: 'David Hasslehoff. Smouldering.'
last_modified_at: 2020-12-29
---

There are many built-in error classes in Ruby and Rails. Most of these errors are subclasses of Ruby’s StandardError. You can find more information in the relevant [Ruby docs](https://ruby-doc.org/core-2.4.2/StandardError.html).

## Instead of…

…rescuing `Exception`.

```ruby
def your_method
  # do something
rescue Exception => e
  # saved ALL THE THINGS
end
```

## Or…

…a non-specific `rescue` that implicitly rescues `StandardError`.

```ruby
def your_method
  # do something
rescue => e
  # saved StandardError and all subclasses
end
```

### Use…

…`rescue` on a specific named error.

```ruby
def your_method
  # do something
rescue SpecificProblemError => e
  # saved only what you meant to
rescue AnotherProblemError => e
  # saved a different kind of error
end
```

## But why?

Ruby’s `Exception` is the parent class to _all_ errors. “Great” you might say, “I want to catch all errors”. But you don’t.

`Exception` includes the class of errors that can occur outside your application. Things like memory errors, or `SignalException::Interrupt` (sent when you manually quit your application by hitting Control-C). These are errors you _don't_ want to catch in your application as they are generally serious and related to external factors. Rescuing `Exception` can cause very unexpected behaviour.

`StandardError` is the parent of most Ruby and Rails errors. If you catch `StandardError` you’re not introducing the problems of rescuing `Exception`, but it is not a great idea. Rescuing _all_ application-level errors might cover up unrelated bugs you don’t know about.

The safest approach is to rescue the error (or errors) you are expecting and deal with the consequences of that error inside the `rescue` block.

In the event of an unexpected error in your application you want to know that a new error has occurred and deal with the consequences of _that_ new error inside its own `rescue` block.

Being specific with `rescue` means your code doesn't accidentally swallow new errors. You avoid subtle hidden errors that lead to unexpected behaviour for your users and bug hunting for you.
