---
title: "Protect your sign up form with Rack::Attack"
description: "Slow down the malicious robots"
layout: article
category: ruby
image:
  base: "2019/protect-your-sign-up-form-using-rack-attack"
  alt: "Clipboard sign up"
  source: "https://unsplash.com/photos/lUShu7PHIGA"
  credit: "Eco Warrior Princess"
---

When your application becomes popular it may attract the attention of hackers, who’ll try and find ways to exploit the weaknesses in your site to use it for nefarious means!

They’ll nearly always explore your site manually, signing up and testing attack vectors, before attempting to automate the weaknesses they’ve discovered.

During an attack, the hacker’s bots will typically sign up with a random email then do something bad, hundreds of times a minute, from a relatively small number of computers.


## Instead of…

…allowing unlimited sign up attempts.


## Use…

…`Rack::Attack` to limit the frequency of sign ups and ban the offending IP addresses.

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
  Rack::Attack.throttle("users/sign_up", limit: 3, period: 15.minutes) do |req|
     # Using “vanilla” devise inside a User model
    req.ip if req.path == "/users" && req.post?
  end
end if Rails.env.production?
```


## But why?

The judicious use of endpoint-based request restriction can prevent your site from being an attractive target for spammers and hackers. It can also reduce the size of any successful bot attack by limiting the amount of possible signups.

In this example, hackers can only add up to three users every quarter of an hour. You _could_ also likely increase the `period` duration to twenty or thirty minutes without accidentally blocking any legitimate users.


### Why not?

The solution above could, _in theory_, block legitimate sign ups, but it is highly unlikely that a user would incorrectly attempt to sign up three times in relatively quick succession.
