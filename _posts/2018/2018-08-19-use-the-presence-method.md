---
title: Use the presence method
description: 'An unsung gem from Active Support'
layout: article
category: ruby
image:
  base: '2018/use-the-presence-method'
  alt: 'Ghostly'
  source: 'https://unsplash.com/photos/ZC0EbdLC8G0'
  credit: 'Stefano Pollio'
---

Active Support takes a lot flak because it adds methods to core Ruby libraries, most notably patching a lot of functionality into Ruby's `Object` class.

Every object in Ruby is a subclass of `Object`, thus if you add methods to it, you're adding them to _every_ object in your code.

Have a look at [the documentation for the enhancements in Active Support](https://api.rubyonrails.org/classes/Object.html#method-i-presence) to find out more.

One of these methods is `#presence`, which I don't see used as much as the more familiar `#blank?` and `#present?`.


## Instead of…

…using long-winded conditionals to display the value of a variable.

```ruby
class User < ApplicationRecord
  validates :email, presence: true

  def friendly_name
    if nickname.present?
      nickname
    elsif given_name.present?
      given_name
    else
      email.split('@').first
    end
  end
end
```


## Use…

…the `#presence` method from Active Support.

```ruby
class User < ApplicationRecord
  validates :email, presence: true

  def friendly_name
    nickname.presence || given_name.presence || email_local_part
  end

  private

  def email_local_part
    email.split('@').first
  end
end
```

## But why?

Use of the `#presence` method provides a very convenient shortcut to return either the object (if it exists) or `nil`.

It is the equivalent of writing `object.present? ? object : nil`, which is a pattern you often see in views in Rails where data may or may not exist.

It's also a nice solution when you have an empty string or array. In those cases `#presence` returns `nil`.


### Why not?

This `#presence` method is only available in Rails. If you're only using Ruby it's probably not worth including Active Support just for this.

Even when using Rails there can be understandable resistance to Rails' habit of extending standard Ruby classes.

Altering standard classes in your own code, by [monkey patching](https://en.wikipedia.org/wiki/Monkey_patch), often causes bugs when the standard Ruby classes begin to behave in unexpected ways. This is the main source of the concern about this style of coding.

Your level of concern about the pitfalls of monkey patching _might_ be strong enough to avoid it even when Rails does it.

Given Rails is a diligently maintained and widely used set of libraries, I consider all and any of it to be safe to use if it makes the resulting code clearer.
