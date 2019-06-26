---
title: "Using strftime in a Rails view is probably a mistake"
description: "I heard you like the % character"
layout: article
category: ruby
image:
  base: '2019/using-strftime-in-a-rails-view-is-probably-a-mistake'
  alt: 'Old broken clocks'
  credit:  Heather Zabriskie
  source: "https://unsplash.com/photos/yBzrPGLjMQw"

---

The `strftime` method appears in many languages, [all the way back to C](https://en.wikipedia.org/wiki/C_date_and_time_functions#strftime)!

The syntax of the (mostly impenetrable) time formatting arguments haven’t changed that much in years and are comprehensively covered in the [Ruby documentation for strftime](https://ruby-doc.org/core-2.6.3/Time.html#method-i-strftime). They're remarkably consistent across languages!

However when `strftime` is used in your views, there's a high chance it will lead to confusion and inconsistency.


## Instead of…

…using `strftime` in your views to format dates and times:

```erb
<%= @user.last_signed_in_at.strftime("%m-%e-%y %H:%M") %>
```


## Use…

…the built in Rails time and date formats. Or add to them.

### `config/initializers/time_formats.rb`

```ruby
Date::DATE_FORMATS[:stamp] = "%Y%m%d" # YYYYMMDD
Time::DATE_FORMATS[:stamp] = "%Y%m%d%H%M%S" # YYYYMMDDHHMMSS
```

…then in the views.

```erb
<%= @user.last_signed_in_at.to_s(:stamp) %>
```


## Why?

By using a method with confusing and complex arguments in your views you’re setting yourself up for inconsistency.

The main benefit for setting up global application date and time formats is for the developers who come after you. The result is a small number of consistent and pre-determined ways to present time through out your application, plus future developers can be spared building their own complicated formats!

Users benefit from this consistency too. If dates and times are always presented in the same way, it takes less time for them to parse. I.e. Ensuring you always say “Jun 11” rather than “11 Jun”; It's a small thing, but worth sweating the details.

You can also use Ruby’s `proc`s to further enhance date and time formatting where basic `strftime` usage wouldn’t be enough. See the [code for the `long_ordinal` format](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/time/conversions.rb#L15-L18) for an example.

There’s a couple of useful sites that can help you get exactly the date formatting you prefer.

[For A Good Strftime](https://www.foragoodstrftime.com) contains a visually pleasant reference for `strftime` formatting strings and lets you build a live date format you can use application-wide.

[Strftimer](http://strftimer.com) lets you paste in a real string representation of a date of time and returns the `strftime` date format string that would produce that formatting.

Rails also includes some defaults and there’s a site that spells out the [Rails Date and Time formats](https://railsdatetimeformats.com). Because I could never remember them and they were hard to find in the documentation.


## Why not?

There’s no real performance harm in calling `strftime` in views. This is about about organisation and consistency.
