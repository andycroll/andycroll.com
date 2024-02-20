---
title: "Validate Email Addresses"
description: "There’s a surprising number of ways to do it"
layout: article
category: ruby
date: 2024-02-26 06:00
image:
  base: "2024/validate-email-addresses"
  alt: "Envelopes"
  credit: "Joanna Kosinska"
  source: "https://unsplash.com/photos/envelope-paper-lot-uGcDWKN91Fs"
---

Ensuring you have data that makes sense is why Rails provides [validations](https://guides.rubyonrails.org/active_record_validations.html) through the Active Model library, which underpins Active Record.

Making sure you can email your users is one of the most important thing to get right in your application, so you probably already have validation checks around your `User#email` attribute.

## Instead of…

…inventing your own regular expression, or using this one from the [older Rails docs](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates):

```ruby
class User < ApplicationRecord
  validates :email,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i },
    presence: true,
    uniqueness: { case_insensitive: true }
end
```

## Use…

…one of these several better options:

### Devise

A reasonable choice, if you’re already using it for user authentication.

```ruby
class User < ApplicationRecord
  validates :email,
    format: { with: Devise.email_regexp },
    presence: true,
    uniqueness: { case_insensitive: true }
end
```

### `URI`

There has been a regular expression built into the `URI` of Ruby‘s standard library since version 2.2. Here's the [commit adding it](https://github.com/ruby/ruby/commit/e63ab5d3ad289767eab49787e4e33390b0ce74e1).

```ruby
class User < ApplicationRecord
  validates :email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    presence: true,
    uniqueness: { case_insensitive: true }
end
```

It's been in some of the [Rails Guides examples](https://guides.rubyonrails.org/active_record_validations.html#custom-validators).

### `email_address` gem

The validator from the [`email_address` gem](https://github.com/afair/email_address) has other useful enhancements for working with email.

You can use the built-in validator:

```ruby
class User < ApplicationRecord
  validates :email,
    presence: true,
    uniqueness: { case_insensitive: true }

  # attribute needs to be called :email
  validates_with EmailAddress::ActiveRecordValidator
end
```

Or directly use the gem‘s functionality in a `validate` block:

```ruby
class User < ApplicationRecord
  validates :email,
    presence: true,
    uniqueness: { case_insensitive: true }

  validate do |user|
    EmailAddress::Address.new(user.email).valid?
  end
end
```

Or use a [custom validator](https://guides.rubyonrails.org/active_record_validations.html#custom-validators):

```ruby
class User < ApplicationRecord
  validates :email,
    email: true,
    presence: true,
    uniqueness: { case_insensitive: true }

  private

  # You can put this in its own file if you check elsewhere for email validity
  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless EmailAddress::Address.new(value).valid?
        record.errors.add attribute, (options[:message] || "is not an email")
      end
    end
  end
end
```

## Why?

Email formatting is a solved problem. _Re_-solving solved problems always feels like madness to me. Why would you not lean on the experience of the entire Internet for something as common as this?

There are various levels of strictness in the regular expressions that underpin the different options I listed above. Most of them are "healthily conventional” in comparison to the [official RFC](https://github.com/afair/email_address?tab=readme-ov-file#avoiding-the-bad-parts-of-rfc-specification) format of emails, which can allow overly unrealistic, but RFC-valid, machine generated email addresses.

If I were to pick, I’d choose the straightforward `URI` option. The underlying regular expression is sufficiently flexible for all regular use.

However, if I was looking to use the [extra functionality](https://github.com/afair/email_address?tab=readme-ov-file#usage) of the `email_address` gem—domain extraction or detection, normalisation or deconstruction—I’d select one of the approaches using that gem.

If I were validating emails in multiple other places in my application I would certainly consider the—reusable—custom validator approach instead.

## Why not?

The different levels of strictness (and differences in the underlying regular expressions) provided by the options above might cause validation issues for existing records if you’ve been using a hand-rolled option and change the specifications of email validation.

However, it _might_ still be worth doing the work to make sure all your email addresses do validate with the new regular expression.

If you’re starting a new app, just pick one of the decent solutions over doing your own thing, unless you have a _really_ good reason.
