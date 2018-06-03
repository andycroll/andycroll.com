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

If your site becomes popular, or even just long-lasting you might see a bunch of 404 errors in your logs.

Sometimes these errors are for pages like `/wp_login.php` or other PHP files. If you see these, it's likely automated bots scanning the internet for security vulnerabilities in WordPress.

These bots are indiscriminate in their targeting (hence looking for php files in our Rails applications!) and are often installed as malware distributed around the internet.

## Instead of…

...cluttering your logs and potentially slowing your application with bots trying to hack WordPress.


## Use…

...ban their IP addresses with `Rack::Attack`.

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

WordPress is great. Genuinely. And powers an enormous proportion of the world’s websites. However, its longevity and ubiquity mean it is a target for automated attacks against non-updated installations that have security weaknesses.

Simply rejecting these requests before you even hit your application and then banning the bot’s IP address protects your app against high volumes of these requests. Leaving you with better performance, less useless noise in your logs and fewer exceptions.

With Rails `Rack::Attack` uses `Rails.cache` by default to store information about requests and block lists. So in production you'll want to configure Redis, or something similar, if you haven’t already.

This is just one use for the kind of access control that Rack::Attack provides, it’s a terrific tool.


### Why not?

Setting up `Rack::Attack` and its cache, is another dependancy and complication for your app and you might not be seeing these errors yet.

The solution above could, _in theory_, block legitimate users. But this is highly unlikely.
