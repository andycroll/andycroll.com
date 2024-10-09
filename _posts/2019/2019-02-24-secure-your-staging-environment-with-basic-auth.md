---
title: Secure Your Rails Staging Environment with HTTP Basic Authentication
description: Opening up your development environment is a bad idea
layout: article
category: ruby
image:
  base: "2019/secure-your-staging-environment-with-basic-auth"
  alt: "Yellow padlock"
  source: "https://unsplash.com/@chrispanas"
  credit: "Chris Panas"
---

A sensible approach to testing features before you ship them to customers is to use a staging environment that closely resembles your live, customer-facing, production application.

It’s important to make sure that only people inside your organisation can use this testing environment, since it might contain broken features (hopefully not!) or private, production-like, data.

## Instead of…

…leaving your staging environment open for anyone who finds it on the wild Internet.

## Use…

…the basic HTTP authentication in Rails to secure the whole application from non-authorised users…

```ruby
class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV["HTTP_BASIC_USER"],
                               password: ENV["HTTP_BASIC_PASSWORD"],
                               if: -> { ENV["HTTP_BASIC_PASSWORD"].present? }
end
```

…and set the environment (`ENV`) variables for `HTTP_BASIC_USER` and `HTTP_BASIC_PASSWORD` in your staging environment.

## But why?

Giving people access to your staging environment is a bad idea. It might contain unreleased or bug-ridden features. Furthermore, it might even allow free access to normally paid-for functionality in your application, since staging environments are often linked up to sandboxed versions of payment processors for testing.

Using HTTP authentication is the simplest way to block access to your entire site. The logic for the change also sits mostly outside your application so there is less chance to introduce a “staging only” bug.

Another reason to prevent your staging environments from being open to the Internet is that search engines might somehow discover it, crawl it and then you have your staging environment appearing in search results. This increases the chances of users finding and using your non-production application and also possible penalties to your search engine ranking due to “duplicate content”.

## Why not?

You might choose security through obscurity—where you simply hope that no-one finds your staging environment—but that is extremely risky.

You could set up a more sophisticated solution by using a combination of HTTP authorisation and some sort of admin user privileges, or even limiting access by location or via a VPN.

You could also implement a similar approach at the `rack` middleware level (using [`Rack::Auth::Basic`](https://github.com/rack/rack/blob/main/lib/rack/auth/basic.rb)) which sits fully outside of your Rails code. See [an example of this](https://blog.arkency.com/common-authentication-for-mounted-rack-apps-in-rails/) from the Arkency blog.

However, basic HTTP authentication in the `ApplicationController` is a fast, simple way to limit access while maintaining parity of behaviour between your staging and production environments.

### Thanks…

…to [Dan](https://twitter.com/dannyguk) for the succinct syntax used in this issue. I’d been using something slightly more long-winded.
