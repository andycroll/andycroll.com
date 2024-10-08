---
title: Delegate to simplify your code
description: "There’s both a Ruby and a Rails version"
layout: article
category: ruby
image:
  base: "2018/delegate-to-simplify-your-code"
  alt: "Graffiti arrows"
  source: "https://unsplash.com/@anniespratt"
  credit: "Annie Spratt"
---

One way of thinking about object-oriented programming is as passing messages between objects.

In many cases you may want to surface a public method on a associated object as if it was a method on the original object.

The two main ways to do this are:

- the `Forwardable` functionality in the the Ruby Standard Library, [documentation here](https://ruby-doc.org/stdlib-2.5.1/libdoc/forwardable/rdoc/Forwardable.html#method-i-def_delegator).
- the `delegate` method, an Active Support core extension (available if you’re using Rails) [documentation here](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/module/delegation.rb).

## Instead of…

… creating new methods to call directly to associated objects.

```ruby
# Plain Ruby
class Workspace
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def user_email
    @user.email
  end
end

# Inside Rails
class Workspace < ApplicationRecord
  belongs_to :user

  def user_email
    user.email
  end
end
```

## Use…

…the `Forwardable` functionality or `delegate` method..

```ruby
# Plain Ruby
class Workspace
  extend Forwardable

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def_delegator :@user, :email, :user_email
end

# Inside Rails
class Workspace < ApplicationRecord
  belongs_to :user

  delegate :email, to: :user, allow_nil: true, prefix: true
  # allow_nil swallows errors if user is nil
  # prefix makes the name of the method user_email
end
```

## But why?

If you are 'passing through' messages in Ruby or Rails either style is preferable to creating a new method. It’s a clearer expression of what you're trying to achieve in your code. The different look of the code helpfully creates a visual distiction between 'just calling methods on an associated object' and where you're actually implementing new functionality.

As is typical, the Rails version is syntactically neater and provides greater flexibility and functionality. I particularly like the `prefix` and `allow_nil` options. If you're using Rails you may as well use the enhancements that Rails provides for delgation.

### Why not?

When using the method there is no clarity improvement in `workspace.user_email` over `workspace.user.email`. However if you’re changing the method name, for example `workspace.owner_email`, to better show your intent, there may be a benefit.

There are other more involved delegation techniques available using Ruby's `Delegator` library ([documentation here](https://ruby-doc.org/stdlib-2.5.1/libdoc/delegate/rdoc/Delegator.html)) but those are more useful when wrapping entire classes in additional functionality, rather than passing a handful of methods.
