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

Active Support takes a lot flak for the magic it adds to core Ruby libraries including patching a lot of functionality into Ruby's `Object`.

The documentation can be found [here](https://api.rubyonrails.org/classes/Object.html#method-i-presence).

For me, a lot of the delight in Rails comes from the shortcuts it adds. Some features even eventually make their way into Ruby core.


## Instead of…

...using long-winded conditionals to display the value of a variable.

```ruby
class User < ApplicationRecord
  validates :email, presence: true

  def full_name
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

...the `#presence` method from Active Support.

```ruby
class User < ApplicationRecord
  validates :email, presence: true

  def full_name
    nickname.presence || given_name.presence || email_local_part
  end

  private

  def email_local_part
    email.split('@').first
  end
end
```

## But why?

This is a method I don't see used as much as the more familiar `#blank?` and `#present?`.

It provides a very convenient shortcut to return either the object (if it exists) or `nil`.

It is the equivalent of writing `object.present? ? object : nil` which is pattern you often see in Ruby code, where `nil` must often be dealt with.


### Why not?

This `#presence` method is only available in Rails, if you're just using standard Ruby you might not want to include Active Support just for this.

Even when using Rails there can be understandable resistance to Rails' habit of extending standard Ruby classes.

Altering standard classes in your own code, by 'monkey patching', can cause bugs when the standard Ruby classes begin to behave in unexpected ways.

Your level of aversion to side-effects might be enough to avoid this particular piece of Rails' magic.

That said... I consider all of Rails, as a diligently maintained and widely used set of libraries, to be fair game for use if it makes the resulting code clearer.
