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

…sending email inside a callback in your model:

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

It’s clearer to have a simple, procedural, 'list of things to do' inside controller actions, as you can read through from A to Z. I also find that debugging side-effects through a model’s callbacks to be much more cognitively difficult, as you have to keep more context—from more files—in your head.


## Why not?

Using callbacks in models to send email could be considered “the Rails Way”, given examples like this have always been part of the documentation. There’s no _real_ harm in this simple case, but the pain of this approach often only becomes apparent later.

There’s a frequently stated opinion preferring “fat models & thin controllers”; pushing as much functionality as you can into your model layer.

This is more about keeping complexity out of the controller layer, rather than advocating for more use of callbacks creating side-effects. I’d also argue that sending an email, in addition to the model change, isn’t complex.

In situations where controller methods _do_ become complex, I prefer to move the functionality into a plain Ruby “service object”, rather than move it into callbacks.
