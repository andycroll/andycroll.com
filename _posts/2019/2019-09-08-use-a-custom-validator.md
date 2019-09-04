---
title: "Use a custom validator"
description: "A little structure for repeated checks"
layout: article
category: ruby
image:
  base: '2019/use-a-custom-validator'
  alt: 'Dropped Ice Cream'
  credit: Sarah Kilian
  source: "https://unsplash.com/photos/52jRtc2S_VE"

---

ActiveModel’s validations, used by calling `validates` inside your model with various options, can be supplemented with your own custom classes. The Rails Guides contains [a section on custom validations](https://guides.rubyonrails.org/active_record_validations.html#custom-validators).


## Instead of...

...using complex code in your `validates` calls:

```ruby
class Invite
  validates :invitee_email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
    message: "is not an email"
  }
end
```

## Use...

...a validator class and extract the logic into it:

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end
```

```ruby
class Invite
  validates :invitee_email, email: true
end
```


## Why?

If you have a validation you might reuse, or that contains complex formatting rules it’s a good idea to break out that functionality into it’s own object.

You can test that logic separately and it provides a more concise explanation of the functionality at the point of use.


## Why not?

There’s a little tip I’ve used in the past in this specific example, of email validation, that is succinct without a validator, but you need to be using `devise` in your application.

```ruby
class Invite
  validates :invitee_email, format: {
    with: Devise.email_regexp,
    allow_blank: false
  }
end
```

It does also work nicely in the validator style as well.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ Devise.email_regexp
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end
```
