---
title: "Turn off the bits of Rails you don't use"
description: "Reduce complexity, reduce overhead"
layout: article
category: ruby
image:
  base: "2021/turn-off-the-bits-of-rails-you-dont-use"
  alt: "Purple lit bank of audio switches"
  source: "https://unsplash.com/photos/n4BDkIEls78"
  credit: "Denisse Leon"
---

The Rails Framework consists of multiple interlocking systems that work together. These systems typically begin with "Action" or "Active" e.g. Active Record, Active Support, Action Pack etc.

You can see the individual componnent gems as directories in the [`rails/rails` repo on github](https://github.com/rails/rails).

There has been a continual process of adding new, useful libraries to Rails ever since its release. Things like Action Cable in Rails 5. Despite the addition of large new sub-frameworks there remains a focus on modularity since [Merb was merged into Rails](https://yehudakatz.com/2008/12/23/rails-and-merb-merge/) in version 3. (This was big Ruby news at the time!)


## Instead of ...

...including the whole of Rails:

### `config/application.rb`

```ruby
require_relative "boot"

require "rails/rails"

# ...
```


## Use...

...only the parts of Rails you want to.

### `config/application.rb`

```ruby
require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# ...
```

This is a fairly typical approach for projects that I spin up.

I often am building apps that do not need email in (Action Mailbox)
or real time WebSockets (Action Cable).

I have also tended to use other solutions for file-uploading (Active Storage) and rich text (Action Text).

Plus, these days, I prefer to use webpack for everything so I disable sprockets. (Although only because I generally _have_ to use webpack for JavaScript!)


## Why?

A slimmed down Rails stack will load and run more quickly because you're literally including less code. How much faster will be dependant on what features you include. The disabling of certain Rails components does allow for the addition of alternatives, e.g. [Sequel](http://sequel.jeremyevans.net) or [rom-rb](https://rom-rb.org) in place of of Active Record.

The main reason to do this is a streamlining of extra configuration and an improvement in general project tidyness.

Just like I'd remove a third-party gem if I wasn't using it, I find it clearer to remove bits of Rails I'm not using.


## Why not?

Rails is integrated. Any 'speed gains' are mostly neglibable once your app is loaded in a production environment.

The components in the 'full' Rails stack are battle-tested, well maintained and nearly always a decent solution, even if your personal preferences lie elsewhere.

If you want to add one of the missing frameworks back into your application you may need to fiddle to get the correct configuration in place.
