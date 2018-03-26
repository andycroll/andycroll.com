---
title: 'Stop robots and crawlers causing errors in your Rails application'
description: 'Beware the remorseless robot army.'
layout: article
category: ruby
image:
  base: '2018/stop-robots-crawlers-triggering-errors-rails'
  alt: 'BB-8'
  source: 'https://unsplash.com/photos/C8VWyZhcIIU'
  credit: 'Joseph Chan'
---

When a Rails application can't find a record, it throws a 404 error. This is a standard HTTP code for browsers meaning 'not found'.

When you have an Internet-facing site various search engines will be crawling it. As you change things, certain URLs might change or cease to exist. This means search engines/crawlers can start generating a lot of ‘not found’ errors by trying to load pages that used to exist.


## Instead of…

...getting a bunch of unhelpful, distracting noise in your monitoring setup, or errors in your logs, when Google (or another web crawler) hits deleted public pages…


### Or...

...naively swallowing all your 404 errors.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found(exception)
    render file:   Rails.root.join('public', '404.html'),
           layout: nil,
           status: :not_found
  end
end
```


## Use…

...the [`is_crawler`](https://github.com/ccashwell/is_crawler) gem and the configure it like so:

### `application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  include IsCrawler

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found(exception)
    if Rails.env.production? && is_crawler?(request.user_agent)
      render_404
    else
      raise exception
    end
  end

  def render_404
    render file:   Rails.root.join('public', '404.html'),
           layout: nil,
           status: :not_found
  end
end
```

One of my sites gets hit by many more crawlers that aren't included by default in the gem. So I add these to the list of crawlers in an initializer:

### `config/initializers/is_crawler.rb`

```ruby
{
  apple: 'Applebot',
  arefs: 'AhrefsBot',
  blexbot: 'BLEXBot',
  dotbot: 'DotBot',
  mailru: 'Mail.RU_Bot',
  magestic12: 'MJ12bot',
  seznam: 'SeznamBot'  
}.each |internal_name, agent_string| do
  Crawler::CUSTOM << Crawler.new(internal_name, agent_string)
end
```


## But why?

If you’re trying to make your app easier to maintain, it’s important to stay on top of your errors. You have probably wired up your application to an error monitoring tool similar to [Rollbar](https://rollbar.com), [Honeybadger](https://honeybadger.io), [Bugsnag](https://bugsnag.com), or [Sentry](https://getsentry.com).

It is tempting to just ignore all 404 errors. However you want to know when real users receive 404 pages, as it might indicate something important is broken.

If you cannot distinguish between the genuine issues that your visitors are having and the ‘noise’ from search engines you cannot focus on fixing _real_ problems.

Whether you’re paying for your tracking service or not, you’ll burn through your credits if you’re receiving a large volume of unnecessary errors.


## Why not?

If most of your site lives behind a sign in, making this change may not be worth the extra effort.
