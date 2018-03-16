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

When a Rails application can't find a record, it throws a 404 error. This is a standard HTTP code for browsers (and other clients) meaning 'not found'.

When you have a Internet-facing site various search engines will be crawling your site. As you change things certain URLs might no longer work and the search engines can start generating a lot of errors by hitting all the links that used to exist.


## Instead of…

Getting a bunch of unhelpful, distracting noise when Google (or another web crawler) hits deleted public pages…


### Or

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

A combination of the [`is_crawler`](https://github.com/ccashwell/is_crawler) gem and logic in your `application_controller.rb`.

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

One of my sites gets hit by many more crawlers, that aren't included by default in the gem. So I add to the list of crawlers in an initializer.

### `config/initializers/is_crawler.rb`

```ruby
Crawler::CUSTOM << Crawler.new(:apple, 'Applebot')
Crawler::CUSTOM << Crawler.new(:arefs, 'AhrefsBot')
Crawler::CUSTOM << Crawler.new(:blexbot, 'BLEXBot')
Crawler::CUSTOM << Crawler.new(:dotbot, 'DotBot')
Crawler::CUSTOM << Crawler.new(:mailru, 'Mail.RU_Bot')
Crawler::CUSTOM << Crawler.new(:magestic12, 'MJ12bot')
Crawler::CUSTOM << Crawler.new(:seznam, 'SeznamBot')
```


## But why?

If you’re trying to make your app easier to maintain, it’s important to stay on top of your errors. You have probably wired your application up to an error reporting tool similar to [Rollbar](https://rollbar.com), [Honeybadger](https://honeybadger.io), [Bugsnag](https://bugsnag.com) or [Sentry](https://getsentry.com).

If you don’t know what are the real issues that your visitors are having and which are ‘noise’ from search engines you cannot focus and fix them. This approach means all the errors in your error provider should be _real_ and cleared out as much as possible - but that’s another article!

You likely don’t want to burn up all your credits with the tracking service, which you might if you’re receiving a large volume of errors.

It is possible to just ‘swallow’ all 404 errors, you most likely want the know when real users receive 404 pages, as it might indicate something important is broken.


## Why not?

This might not be applicable to your domain. If most of your site is behind a sign in, this isn’t worth the extra effort.
