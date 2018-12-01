---
title: Ignore PHP bots with Rack::Attack
description: 'This is not the wp_login.php you’re looking for.'
layout: article
category: ruby
image:
  base: '2018/ignore-php-bots-with-rack-attack'
  alt: 'Robots'
  source: 'https://unsplash.com/photos/xdEeLyK4iBo'
  credit: 'Jehyun Sung'
---

If your site has been around for a long time or starts getting popular, you might see a bunch of 404 errors in your logs.

Sometimes these errors are for pages like `/wp_login.php` or other PHP files. If you see these, it's likely to be automated bots scanning the Internet for security vulnerabilities in WordPress-based sites.

These bots are indiscriminate in their targeting, hence looking for PHP files in our Rails applications!


## Instead of…

…your logs becoming cluttered and these automated bots potentially slowing your application.


## Use…

…`Rack::Attack` to block their requests and ban the offending IP addresses.

#### `Gemfile`

```ruby
gem 'rack-attack'
```

#### `config/application.rb`

```ruby
module YourAppName
  class Application < Rails::Application
    config.middleware.use Rack::Attack
  end
end
```

#### `config/initializers/rack_attack.rb`

```ruby
class Rack::Attack
  Rack::Attack.blocklist('bad-robots') do |req|
    req.ip if /\S+\.php/.match?(req.path)
  end
end if Rail.env.production?
```


## But why?

WordPress powers an enormous proportion of the world’s websites and has done for many years. However, its longevity and ubiquity make it a target for automated attacks. There are a lot of non-updated installations with known security weaknesses.

Rejecting these requests before they even hit your application, then banning the bot’s IP address, leaves you with better performance, less distracting noise in your logs and fewer exceptions raised.

With Rails, `Rack::Attack` uses `Rails.cache` by default to store its information about requests and block lists. By default this uses a memory store, but in production you'll want to use something like Redis to a provide more resilient cache.

This is just one use case for the kind of access control that Rack::Attack provides. It is a terrific tool for protecting your application.


### Why not?

Adding `Rack::Attack` and its cache as another dependency increases the complexity of your application and its infrastructure.

If you're not seeing these sorts of errors, adding this protection as a pre-emptive measure may not be worth it.

The solution above could, _in theory_, block legitimate users, but this is highly unlikely.
