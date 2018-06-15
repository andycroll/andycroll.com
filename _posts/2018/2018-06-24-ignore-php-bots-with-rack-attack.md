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

Sometimes these errors are for pages like `/wp_login.php` or other PHP files. If you see these, it's likely automated bots scanning the internet for security vulnerabilities in WordPress.

These bots are indiscriminate in their targeting (hence looking for php files in our Rails applications!) and are often installed as malware distributed around the internet.


## Instead of…

...cluttering your logs and potentially slowing your application with bots trying to hack WordPress.


## Use…

...`Rack::Attack` to ignore their requests and ban them.

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

WordPress is great. Genuinely. And it powers an enormous proportion of the world’s websites. However, its longevity and ubiquity mean it is a target for automated attacks. There are a lot of non-updated installations with known security weaknesses.

Rejecting these requests before they even hit your application, then banning the bot’s IP address, leaves you with better performance, less distracting noise in your logs and fewer exceptions raised.

With Rails, `Rack::Attack` uses `Rails.cache` by default to store its information about requests and block lists. So in production you'll want to configure Redis, or something similar, if you haven’t already.

This is just one use for the kind of access control that Rack::Attack provides. It is a terrific tool for protecting your application.


### Why not?

Adding `Rack::Attack` and its cache as another dependency increases the complexity of your application and its infrastructure.

You might not be seeing these errors yet, so in that case it may not be worth it.

The solution above could, _in theory_, block legitimate users. But this is highly unlikely.
