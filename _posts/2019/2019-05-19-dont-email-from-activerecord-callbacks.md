---
title: "Don’t Email From Active Record Callbacks"
description: "It’s in the docs, but it’s a bad idea."
layout: article
category: ruby
image:
  base: '2019/dont-email-from-activerecord-callbacks'
  alt: 'Envelopes'
  credit: Joanna Kosinska
  source: "https://unsplash.com/photos/uGcDWKN91Fs"

---

One of the first things you often want to do within your Rails application is send email.

A frequent pattern is that an email is sent after a change to, or creation of, an instance of one of your models.


## Instead of…

…sending email inside a callback in your model.

```ruby
class Comment < ApplicationRecord
  after_create :send_email_to_author

  private

  def send_email_to_author
    AuthorMailer.
      with(author: author).
      comment_notification.
      deliver_now
  end
end
```


## Use…

…the controller to send your email.

```ruby
class CommentsController < ApplicationController
  def create
    Comment.create(comment_params)
    AuthorMailer.
      with(author: author).
      comment_notification.
      deliver_now
  end
end
```


## Why?

This is all about clarity and preventing unintended side effects.

At some point, you’ll likely need to create a comment without emailing the author; perhaps in the `rails console` or in another action. You _can_ use methods that [skip callbacks](https://guides.rubyonrails.org/active_record_callbacks.html#skipping-callbacks), but then you’re into a whole new world of complexity.

I find it clearer to have a simple, procedural, 'list of things to do' inside my controller actions. I also find that debugging side-effects through a model’s callbacks to be much more cognitively difficult.


## Why not?

Technically this could be considered “the Rails Way” given examples like this have always been part of the documentation. There’s no _real_ harm in this simple case, but the pain of this approach often only become apparent later.

There’s an often heard argument for “fat models, thin controllers” but this is more about keeping against complexity in the controller method rather than advocating for callbacks. I’d also argue that sending an email isn’t that complex.

When controller methods do eventually become complex I prefer to move the functionality into a plain Ruby “service object” that performs the task, rather than move things into callbacks.
