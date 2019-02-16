---
title: Secure Your Rails Staging Environment with HTTP Basic Authentication
description: Opening up your development environment is a bad idea
layout: article
category: ruby
image:
  base: '2019/secure-your-staging-environment-with-basic-auth'
  alt: 'Yellow padlock'
  source: "https://unsplash.com/photos/0Yiy0XajJHQ"
  credit: "Chris Panas"
---

A sensible approach to testing features before you ship them to customers is to use a staging environment that closely resembles, your live, customer-facing, production application.

It’s important to make sure that only people inside your organisation can use this testing environment, it might contain broken features (hopefully not!) or


## Instead of…

…leaving your staging environment open for anyone who finds it on the wild internet.


## Use…

…the basic HTTP authentication in Rails to secure the whole application from non-authorised users.

```ruby
class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV["HTTP_BASIC_USER"],
                               password: ENV["HTTP_BASIC_PASSWORD"],
                               if: -> { ENV["HTTP_BASIC_PASSWORD"].present? }
end
```

…and set the environment (`ENV`) variables for `HTTP_BASIC_USER` and `HTTP_BASIC_PASSWORD` in your staging environment.


## But why?

Giving people access to your staging environment is a bad idea. It might contain unreleased or bug-ridden features. Or perhaps even allow access to the functionality of you application for free as staging environments are often linked up to sandboxed versions of payment processors for testing.

This is pretty much the simplest way to block access to your entire site, plus it's


## Why not?

You might choose security through obscurity (where you simply hope that no-one finds your staging environment) but that feels risky to me.

There’s certainly options to aim for something more sophisticated by using a combination of HTTP authorisation and some sort of admin user privileges, or even limiting access by location or via a VPN.

However, this solution is a fast, simple way to limit access and also to not change the behaviour (very much) between your staging and production environments. Which after all is one of the points of production-like behaviour of a staging environment.


### Thanks…

…to [Dan](https://twitter.com/dannyguk) for the exact syntax of this approach, I’d been using a more long-winded approach.
