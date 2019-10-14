---
title: "Use Active Support in Rails for deprecation messages"
description: "An internal Rails tool, availible for us"
layout: article
category: ruby
image:
  base: '2019/use-active-support-in-rails-for-deprecation-messages'
  alt: 'Caution on the pavement'
  credit: Goh Rhy Yan
  source: "https://unsplash.com/photos/FFgcWvplwsc"

---

When authors of open source libraries change major functionality they often adhere to something called [semantic versioning](https://semver.org). At its simplest you can think of it as a rule meaning features aren’t removed until a major version is released.

Before any big changes it’s a good idea to send messages to users of the software in a harmless, but visible, way. This is often done via the logs output when the code runs.

You might have seen these when your tests run or in your live application logs.

```
blah/blah/file.rb:34: warning: constant ::Fixnum is deprecated
```

Although in our private codebases our changes do not impact hundreds of other unseen developers, it’s still a good idea to communicate with your team when functionality changes.

The Rails framework goes through this enough that it has [a standard depreciation approach baked into Active Support](https://api.rubyonrails.org/classes/ActiveSupport/Deprecation/Reporting.html), and in _our_ code we can piggyback off the feature they use to deprecate internal features.


## Instead of...

...just logging

```ruby
class Coffee
  def make
    put_instant_in_cup
    add_hot_water
    puts "We should #make_properly with an Aeropress"
  end

  def make_properly
    grind_on_medium_fine
    add_to_inverted_aeropress
    sleep(37)
    invert_and_apply_pressure
  end
  # ...
end
```


## Use...

...Active Support’s deprecation library.

```ruby
class Coffee
  def make
    put_instant_in_cup
    add_hot_water
    ActiveSupport::Deprecation.warn(
      "We should #make_properly with an Aeropress")
  end

  def make_properly
    grind_on_medium_fine
    add_to_inverted_aeropress
    sleep(37)
    invert_and_apply_pressure
  end
  # ...
end
```

When you of your co-workers call `Coffee.new.make` you’ll see...

```
DEPRECATION WARNING: We should #make_properly with an Aeropress
(called from coffee.rb:4)
```

... in your logs.

## Why?

First, instant coffee is horrible and you _just shouldn’t_.

Second, this is a relatively lightweight way to 'soft protect' old ways of doing things in favour of new code.

This is useful in two ways. One as a way to discover places in the code that use your existing method. It might be called in places you don’t expect.

Another is to prevent your coworkers from adding new uses of the deprecated method because, when they attempt to, they’ll see the deprecation message.

Another way to use Rails' deprecation functionality is within scopes. You'd do this when you want to maintain existing logic, but discourage further use.

```ruby
class TakeawayCoffeeCup < ApplicationRecord
  scope :good_choice, -> {
    ActiveSupport::Deprecation.warn("Be more ecologically minded")
    where(material: "cardboard")
  }
  scope :eco_choice, -> {
    where(brand: "keepcup", reusable: true)
  }
end
```

## Why not?

If you’re working on your own, or in the early, “messy”, stages of an application, this is probably overkill.

In a non-Rails app, importing the whole of Active Support might also be a lot of library for a sliver of its functionality.

The principle of deprecation over time is still a good idea though if you're working with other folks.
