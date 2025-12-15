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
last_modified_at: 2020-12-29
---

The `strftime` method appears in many languages, [all the way back to C](https://en.wikipedia.org/wiki/C_date_and_time_functions#strftime). The syntax of the (mostly impenetrable) formatting arguments haven’t changed that much in years and they're remarkably consistent across languages.

Ruby’s version is comprehensively [documented in the Time class](https://ruby-doc.org/core-2.6.3/Time.html#method-i-strftime).

However when `strftime` is used in your views, there's a high chance it will lead to confusion and inconsistency.


## Instead of…

…using `strftime` in your views to format dates and times:

```erb
<%= @user.last_signed_in_at.strftime("%m-%e-%y %H:%M") %>
```


## Use…

…the built in Rails time and date formats. Or add to them, like I do here, creating my own `:stamp` format for `Date` and `Time`.

### `config/initializers/time_formats.rb`

```ruby
Date::DATE_FORMATS[:stamp] = "%Y%m%d" # YYYYMMDD
Time::DATE_FORMATS[:stamp] = "%Y%m%d%H%M%S" # YYYYMMDDHHMMSS
```

Then in the views.

```erb
<%= @user.last_signed_in_at.to_s(:stamp) %>
```


## Why?

By using a method with confusing and complex arguments in your views, you’re setting yourself up for inconsistency.

The main benefit to defining global application date and time formats is for the developers who come after you, including _future_ you. The result is a small number of consistent and pre-determined ways to present time throughout your application, and future developers can be spared building their own formats!

Users benefit from this consistency too. If dates and times are always presented in the same way, it takes less time for them to parse. I.e. Ensuring you always say “Jun 11” rather than “11 Jun”; It's a small thing, but worth sweating the details.

Here's a couple of useful sites that can help you get to exactly the date formatting you prefer:

[For A Good Strftime](https://www.foragoodstrftime.com) contains a visually pleasant reference for `strftime` formatting strings and lets you build a live date format you can use application-wide.

[Strftimer](https://strftimer.com) lets you paste in a real string representation of a date or time and returns the `strftime` date format string that would produce that formatting.

I can never remember the `Date` and `Time` formats that are provided by default, plus they were hard to find in the documents, so _I_ built a site that spells out the [Rails Date and Time formats](https://railsdatetimeformats.com).


## Why not?

There’s no real performance harm in calling `strftime` in views. This is about organisation and consistency.
