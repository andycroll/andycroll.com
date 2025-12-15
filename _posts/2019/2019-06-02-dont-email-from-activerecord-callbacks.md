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
last_modified_at: 2019-06-02
---

One of the first things you often want to do within your Rails application is send email.

A frequent pattern is that an email is sent after a change to, or creation of, an instance of one of your models.


## Instead of…

…sending email inside a callback in your model:

```ruby
class BookReview < ApplicationRecord
  after_create :send_email_to_author

  private

  def send_email_to_author
    AuthorMailer.
      with(author: author).
      review_notification.
      deliver_now
  end
end
```


## Use…

…the controller to send your email.

```ruby
class BookReviewsController < ApplicationController
  def create
    BookReview.create(comment_params)
    AuthorMailer.
      with(author: author).
      review_notification.
      deliver_now
  end
end
```


## Why?

This is all about clarity and preventing surprises when you come back to the code.

Let's consider the example above. Creating a review doesn’t _always_ need to send an email to the author of the book. In the first code sample, the email sending happens as a side effect of creating a new book review.

At some point, you’ll likely need to create a review without emailing the author; perhaps in the `rails console` or in another action. You _can_ use methods that [skip callbacks](https://guides.rubyonrails.org/active_record_callbacks.html#skipping-callbacks), but then you’re into a whole new world of complexity.

It’s clearer to have a simple, procedural, 'list of things to do' inside controller actions that you can read through from A to Z. In this case, having the email sending be a separate _thing_ that happens after the creation of the review makes things much more obvious when you come back to the code later.

In addition, debugging tangential functionality through a model’s callbacks is much more cognitively difficult, as you have to keep more context—from more files—in your head.


## Why not?

Using callbacks in models to send email could be considered “the Rails Way” given examples like this have always been part of the documentation. And there’s no _real_ harm in this simple case, but the pain of this approach often only becomes apparent later as the complexity of your application increases.

There’s a frequently stated colloquial recommendation that we should prefer “fat models and thin controllers”, pushing as much functionality as you can into your model layer. This is generally good advice. But, it is more about keeping complexity out of the controller layer, by making the activities of your application clear, rather than advocating for more use of side effect-generating callbacks.

I’d also argue that sending an email alongside a model change is not complex enough to merit a confusing callback-based abstraction. It is important to be clear that these _two_ important things will happen to users of your application when this controller action is called.

In situations where controller methods _do_ become complex, I prefer to move the functionality into a plain Ruby “service object”, rather than move it into callbacks.
