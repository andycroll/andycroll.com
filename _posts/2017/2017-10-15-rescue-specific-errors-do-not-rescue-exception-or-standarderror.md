---
title: 'Rescue specific errors. Don’t rescue Exception or StandardError'
description: 'Rescuing all the things is bad.'
layout: article
category: ruby
image:
  base: '2017/rescue-specific-errors-do-not-rescue-exception-or-standarderror'
  alt: 'David Hasslehoff. Smouldering.'
---

There are many built-in error classes in Ruby & Rails. Most of these errors are subclasses of Ruby’s StandardError. [Ruby docs](http://ruby-doc.org/core-2.4.2/StandardError.html) are here.

## Instead of…

…rescuing `Exception`.

```ruby
def your_method
  # do something
rescue Exception => e
  # saved it
end
```

## Use…

…an implicit `rescue` that rescues `StandardError`.

```ruby
def your_method
  # do something
rescue => e # actually StandardError
  # saved it
end
```

### Or, much better…

…rescue a specific named error.

```ruby
def your_method
  # do something
rescue SpecificProblemError => e
  # saved it
end
```

## But why?

Ruby’s `Exception` is the parent class to _all_ errors. “Great” you might say, “I want to catch all errors”. But you don’t.

`Exception` includes the class of errors that can occur outside your application. Things like memory errors, or `SignalException::Interrupt` (sent when you manually quit your application by hitting control-c).

So don’t rescue `Exception`.

`StandardError` is the parent of most Ruby and Rails errors. If you catch `StandardError` you’re doing much better.

The clearest approach is to only rescue the errors you are expecting. It is likely you will want to _know_ that an unusual error has occurred. So rescuing all application-level errors (via `StandardError`) might cover up bugs you don’t know about.

Be specific to avoid nasty surprises for your users & bug hunting for you.
