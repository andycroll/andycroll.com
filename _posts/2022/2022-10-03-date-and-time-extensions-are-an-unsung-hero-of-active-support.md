---
title: "Time extensions are an unsung hero of Active Support"
description: "There’s a method for that"
layout: article
category: ruby
image:
  base: "2022/time-ranges-are-an-unsung-hero-of-active-support"
  alt: "Calendar with pins"
  credit: "Towfiqu barbhuiya"
  source: "https://unsplash.com/photos/bwOAixLG0uc"

---

In Active Support‘s extensions to the core Ruby classes, some of the most useful and plentiful are related to `Time`.

One of Rails’s founding uses was to provide helpful, reusable methods for regularly performed tasks. In our web applications we‘re often using time periods.

Enter the methods from [DateAndTime::Calculations](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/date_and_time/calculations.rb), or see the [API documentation](http://api.rubyonrails.org/classes/DateAndTime/Calculations.html) or the [`DateTime` section in the Core Extensions Rails guide](http://guides.rubyonrails.org/active_support_core_extensions.html#extensions-to-datetime).


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

This is one of those cases where the ORM (and the tooling around it) get in the way and introduce unforseen performance issues.

The `.where` scope has an implicit `ORDER` scope on the primary key that isn't obvious at first glance.

```ruby
User.where(email: "andy@goodscary.com")
# SELECT "users".*
# FROM "users"
# WHERE "users"."email" = "andy@goodscary.com"

User.where(email: "andy@goodscary.com").first
# SELECT "users".*
# FROM "users"
# WHERE "users"."email" = "andy@goodscary.com"
# ORDER BY "users"."id" ASC
# LIMIT 1

User.find_by(email: "andy@goodscary.com")
# SELECT "users".*
# FROM "users"
# WHERE "users"."email" = "andy@goodscary.com"
# LIMIT 1
```

Straightforward indexes on our database didn't help us as in our—more complex—case. We were querying using an index, but because we were using `.where().first` we were inadvertently doing a non-indexed scan to establish the order, which caused enormous performance problems.

Additionally, we were writing many thousands of rows per second and, even with a _monstrously_ powerful database, we were seeing issues because the entire table was being sorted to then pick only one record.

Debugging this issue was tricky because it is not possible to call `.to_sql` on the results of `.find_by` or `.where().first` as the query executes and you have to use logging to work out the exact SQL that is being generated.

Knowing the exact SQL Active Record is generating from methods that might _seem_ the same on the surface can be _very_ important.


## Why not?

In small tables, under light load, the performance impact of using `where().first` would be negligible.

