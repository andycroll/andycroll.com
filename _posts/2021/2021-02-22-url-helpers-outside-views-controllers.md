---
title: "Use Rails URL helpers outside view and controllers"
description: "Sometimes useful to have in a job or model"
layout: article
category: ruby
image:
  base: "2021/url-helpers-outside-views-controllers"
  alt: "Abstract greyscale roads"
  source: "https://unsplash.com/photos/36b7JBzhfF4"
  credit: "Bogdan Karlenko"
---

Occasionally you'll need to generate a URL for your own application outside views or controllers where your URL helpers are available. These helper methods are [generated form your routes](https://guides.rubyonrails.org/routing.html#path-and-url-helpers), e.g. `user_books_path(user)`.


## Instead of ...

...hard coding a URL:

```ruby
class RequestUserCallBackJob < ApplicationJob
  def perform(user)
    Net::HTTP.post(
      "http://userinfoapi.com/",
      body: {callback_to: "https://myapp.com/user/#{user.id}"})
  end
end
```


## Use...

...the route helpers that Rails includes automatically in controllers.

```ruby
class RequestUserCallBackJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(user)
    Net::HTTP.post(
      "http://userinfoapi.com/",
      body: {callback_to: user_url(user, host: "myapp.com")})
  end
end
```

You'll need to ensure you specify a `host` for any URLs you generate as the URL helpers are expecting the context of an HTTP request (which is always available in the views and controllers) which sets that option.

An enhanced version of this pattern is to use an Active Support concern and piggyback on the (probably) already set Action Mailer url options.

```ruby
module Routing
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
end

class RequestUserCallBackJob < ApplicationJob
  include Routing

  def perform(user)
    Net::HTTP.post(
      "http://userinfoapi.com/",
      body: {callback_to: user_url(user)})
  end
enda
```


## Why?

It's better to use the URL helpers throughout your application since they're convenient and consistent. Should you change a route for any reason and fail to update the relevant URL method, your tests will alert you to the problem. You wouldn't get this advance warning if you had interpolated an `id` into a hard-coded URL.

As demonstrated in the example above, I typically find I need this pattern when calling out to external APIs that require a webhook to listen for a response.

Another use case might be if you're writing an API for your application that includes a field describing URLs of resources in your application. However in that case you might want to build or use tooling, such as [`active_model_serializers`](https://github.com/rails-api/active_model_serializers), to better support it. API responses are more akin to views and probably deserve their own


## Why not?

If you're trying to use route helpers in a place where they aren't already included, this might be an indication that this is a place you _shouldn't_ be using them.

Avoid using your routes within an Active Record model, there's almost certainly a better place!
