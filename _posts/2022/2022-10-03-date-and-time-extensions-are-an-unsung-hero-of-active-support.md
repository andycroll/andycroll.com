---
title: "Time extensions are an unsung hero of Active Support"
description: "Is the end of the quarter of Tuesday, a week from now, a Sunday? There’s a method for that."
layout: article
category: ruby
image:
  base: "2022/time-ranges-are-an-unsung-hero-of-active-support"
  alt: "Calendar with pins"
  credit: "Towfiqu barbhuiya"
  source: "https://unsplash.com/photos/bwOAixLG0uc"

---

In Active Support‘s extensions to the core Ruby classes, some of the most useful and plentiful are related to `Time`.

One of Rails’s founding uses was to provide helpful, reusable methods for regularly performed tasks. In our web applications we‘re often working with times and dates.

Enter the methods from [DateAndTime::Calculations](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/date_and_time/calculations.rb). To find out more check out out the [API documentation](http://api.rubyonrails.org/classes/DateAndTime/Calculations.html) or the [`DateTime` section in the Core Extensions Rails guide](http://guides.rubyonrails.org/active_support_core_extensions.html#extensions-to-datetime).


## Familiarise yourself with...

...the extensions to `Date`:

```ruby
today = Date.today
#=> Mon, 03 Oct 2022
today.end_of_week
#=> Sun, 09 Oct 2022
today.beginning_of_month
#=> Sat, 01 Oct 2022
today.end_of_quarter
#=> Sat, 31 Dec 2022
today.beginning_of_year
#=> Sat, 01 Jan 2022
today.all_day
#=> Mon, 03 Oct 2022 00:00:00.000000000 UTC +00:00..Mon, 03 Oct 2022 23:59:59.999999999 UTC +00:00
today.all_week
#=> Mon, 03 Oct 2022..Sun, 09 Oct 2022
today.all_month
#=> Sat, 01 Oct 2022..Mon, 31 Oct 2022
today.all_year
#=> Sat, 01 Jan 2022..Sat, 31 Dec 2022
today.on_weekday?
#=> true
today.next_occurring(:thursday)
#=> Thurs, 06 Oct 2022
```

...and `DateTime`:

```ruby
right_now = Time.zone.now
#=> Mon, 03 Oct 2022 08:30:23.666835000 UTC +00:00
right_now.beginning_of_day
#=> Mon, 03 Oct 2022 00:00:00.000000000 UTC +00:00
right_now.end_of_week
#=> Sun, 09 Oct 2022 23:59:59.999999999 UTC +00:00
right_now.beginning_of_month
#=> Sat, 01 Oct 2022 00:00:00.000000000 UTC +00:00
right_now.end_of_quarter
#=> Sat, 31 Dec 2022 23:59:59.999999999 UTC +00:00
right_now.beginning_of_year
#=> Sat, 01 Jan 2022 00:00:00.000000000 UTC +00:00
right_now.all_day
#=> Mon, 03 Oct 2022 00:00:00.000000000 UTC +00:00..Mon, 03 Oct 2022 23:59:59.999999999 UTC +00:00
today.all_week
#=> Mon, 03 Oct 2022 00:00:00.000000000 UTC +00:00..Sun, 09 Oct 2022 23:59:59.999999999 UTC +00:00
today.all_month
#=> Sat, 01 Oct 2022 00:00:00.000000000 UTC +00:00..Mon, 31 Oct 2022 23:59:59.999999999 UTC +00:00
right_now.all_year
#=> Sat, 01 Jan 2022 00:00:00.000000000 UTC +00:00..Sat, 31 Dec 2022 23:59:59.999999999 UTC +00:00
right_now.on_weekday?
#=> true
right_now.next_occurring(:thursday)
#=> Thurs, 06 Oct 2022 08:30:23.666835000 UTC +00:00
```


## Why?

These are tremendously useful, and well-named, methods to help describe the date and time logic in your applications.


## Why not?

While this style of extending core Ruby classes is sometime derided by folks who dislike Rails’s ”magical” style... you’d be a bit silly to reimplement your own date calculations inside a Rails application.


