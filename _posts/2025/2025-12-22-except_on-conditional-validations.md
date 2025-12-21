---
title: "Skip Validations in Specific Contexts with except_on"
description: "In _validation callbacks too."
layout: article
category: ruby
date: 2025-09-07 09:00
image:
  base: "2025/except_on-conditional-validations"
  alt: "Pile of receipts one says not valid for travel"
  credit: "Duskfall Crew"
  source: "https://unsplash.com/photos/pile-of-receipts-one-says-not-valid-for-travel-dtkbdE4YKj8"
---

Rails 8.0 added `except_on` as an [option to validations](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each). It's the inverse of `on:` and lets you skip validations in specific contexts.

## Instead of...

...skipping all validations in your controller:

```ruby
class Admin::UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save(validate: false)  # Skips ALL validations!
      redirect_to admin_users_path
    else
      render :new
    end
  end
end
```

...using methods that bypass Active Record entirely:

```ruby
class User < ApplicationRecord
  def self.admin_create(attributes)
    user = new(attributes)
    user.update_columns(attributes)  # No validations, no callbacks
  end
end
```

This example uses a class method on the model, but you might see similar code in _something like_ a `UserFactory` or `UserCreationService` in your application.


## Use...

```ruby
class User < ApplicationRecord
  validates :birthday, presence: true, except_on: :admin_create
end

# Admin creates user without birthday
user = User.new(name: "Jane")
user.save(context: :admin_create) # => true

# Regular save still requires birthday
user.save # => false
```

You can also stack multiple contexts.

```ruby
validates :email, 
  format: { with: URI::MailTo::EMAIL_REGEXP },
  except_on: [:admin_create, :bulk_import]
```

### Extending this to callbacks

[Validation callbacks get the same treatment](https://github.com/rails/rails/pull/54665) in Rails 8.1.

```ruby
before_validation :normalize_email, except_on: :quick_signup
after_validation :check_email_uniqueness, except_on: [:admin_create, :bulk_import]
```

Now your callbacks follow the same pattern as your validations. Consistency wins.


## Why?

Your admin interface needs to create users without complete data. Your data import skips some business rules. Perhaps your API has different requirements than your web forms.

Previously, you'd handle this with dangerous workarounds, seperate "factory" objects, or repetitive code.


## Why not?

Every skipped validation is a possible data integrity issue. But that's also true of the other approaches.

_Real_ database constraints can act as your safety net for true data consistency.

A form object or separate model might make more sense for your application or team but you might be fighting the framework.

You also have to consider whether the validation is _really_ required if your application breaks somewhere else with that incomplete data breaks your mailer.

*`except_on` can keep validations concise while making intent clear: "validate everywhere except here." Just remember: with great power comes great responsibility.* And some folks will hate this as much as they hate callbacks.