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

The Rails Framework consists of multiple subsystems that work together. The names of these systems typically begin with "Action" or "Active" e.g. Active Record, Active Support, Action Pack etc.

You can see the individual component gems as directories in the [`rails/rails` repo on GitHub](https://github.com/rails/rails).

There has been a continual process of adding new, useful libraries to Rails ever since its release. For example, the addition of web socket support via Action Cable was a major feature of Rails 5. Despite the addition of large new sub-frameworks there remains a focus on modularity since [Merb was merged into Rails](https://yehudakatz.com/2008/12/23/rails-and-merb-merge/) in version 3. (This was big Ruby news at the time!)


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

Often apps do not need to receive email (Action Mailbox) or real-time WebSockets (Action Cable).

There are also other solutions for file uploading (Active Storage) and rich text (Action Text).

Plus, these days, you might prefer to use webpack for everything. In that case, it makes sense to disable sprockets.


## Why?

A slimmed down Rails stack will load and run more quickly because you're literally including less code. How much faster will be dependant on what features you include.

The main reason to do this is a streamlining of extra configuration and an improvement in general project tidyness.

It's a good idea to remove a third-party gem if you aren't using it. In the same way, it is often clearer to remove bits of Rails that are not being used.

Additionally, if you want to use alternatives to certain Rails subsystems — perhaps something like [rom-rb](https://rom-rb.org) in place of Active Record — you might want to disable Active Record rather than use them both side-by-side.

## Why not?

Rails is integrated. Any 'speed gains' are mostly neglibable once your app is loaded in a production environment.

The components in the 'full' Rails stack are battle-tested, well maintained, and nearly always a decent solution, even if your personal preferences lie elsewhere.

If you want to add one of the missing frameworks back into your application it might be fiddly to get the correct configuration in place.
