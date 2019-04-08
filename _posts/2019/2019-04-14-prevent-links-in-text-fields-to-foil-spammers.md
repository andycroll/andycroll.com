---
title: "Prevent Links in Text Fields to Foil Spammers"
description: "Bad guys on the internet are inventive."
layout: article
category: ruby
image:
  base: "2019/prevent-links-in-text-fields-to-foil-spammers"
  alt: "SPAM. Spam. Lovely Spam."
  source: "https://www.flickr.com/photos/jeepersmedia/14014120505/"
  credit: "Mike Mozart"
---

Your application most likely sends email even if that is not a primary function of the product: invites, messages & forgot password reminders.

As soon as you allow user generated content in those emails your application becomes an interesting target for email spammers.

Email clients like Apple Mail & Gmail automatically highlight strings of text that look like web addresses. So by simply inserting strings that resemble web addresses they can use text fields to direct users to nefarious websites, they don't even have to inject HTML.


## Instead of…

…allowing naughty spammers to use the email sending functionality of your application.

```erb
<%= form_for :invitee do |f| %>
  Email: <%= f.text_field :email %>
  Message : <%= f.text_field :message %>
  <%= f.submit "Send Email" %>
<% end %>
```


## Always…

…use a validation to prevent the insertion of web addresses into you text fields.

```erb
<%= form_for :invitee do |f| %>
  Email: <%= f.text_field :email %>
  Message : <%= f.text_field :message %>
  <%= f.submit "Send Email" %>
<% end %>
```


#### `validators/no_urls_validator.rb`

```ruby
class NoUrlsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    if value.match?(%r{(http|\w+\.\w+\/?)})
      record.errors[attribute] << (options[:message] || "looks like it contains a web address")
    end
  end
end
```


#### `app/models/invitee.rb`

```ruby
class Invitee
  # ...
  validates :message, no_urls: true
  # ...
end
```


## But why?

This isn’t an obvious issue, but definitely one spammers have worked out. If your application allows sending of any email before requesting payment, you are a target.

While protecting browsers from user-generated HTML and JavaScript has been a part of Rails’ rendering since the beginning this issue of email clients automatically linking website-ish, non-HTML, text happens beyond our application’s boundaries.

If you validate your user-entered text, you’ll be less of a target for spammers.


## Why not?

The regular expression I've used in the validator is pretty naive and may result in false positives. It rejects any string containing “`http`” or any two words joined by a full stop character: “`like.this`”.

You might finesse the regular expression to match a more specific pattern.

Instead of rejecting the text with a validation, and sending an error message to the user, you might automatically fix the text in a callback, perhaps adding a space after every full stop.

```ruby
"like.this".tr(".", ". ")
#=> "like. this"
```

Additionally you might want to find another way to restrict text input or features until your users have become paying customers—a credit card is often a good barrier to spammers.
