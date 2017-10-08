---
title: "Use Rails’ naming conventions for dates & times"
description: 'Use _at & _on for times & dates in Rails'
layout: article
category: ruby
image:
  base: '2017/use-rails-naming-conventions-for-dates-and-times'
  alt: 'dates'
  credit: 'Roman Bozhko'
  source: 'https://unsplash.com/photos/PypjzKTUqLo'
---

Rails includes the default managed timestamps `updated_at` and `created_at` for ActiveRecord models.

However, on many applications, diving into a `schema.rb` or migration often reveals `something_date` as a field name on a model.


## Instead of…

...including the words `date` or `time` in your database columns:

```ruby
class NaughtyMigration < ActiveRecord::Migration[5.1]
  add_column :users, :logged_in_date, :datetime
  add_column :users, :logged_out_time, :date
end
```


## Use…

...the suffix `at` for times and `on` for dates.

```ruby
class AwesomeMigration < ActiveRecord::Migration[5.1]
  add_column :users, :logged_in_at, :datetime
  add_column :users, :logged_out_on, :date
end
```


## But why?

Including the word `time` or `date` in the variable name is redundant and adds to the visual noise of the code. You don’t say `first_name_string`, do you?

Given Rails' conventions, something like a `due_on` field lets you know to expect a date. You give instant feedback to anyone reading your code about the expected data stored in the database.

I _might_ allow myself the occasional `_until` if it makes the variable easier to read.

For me, the naming constraint also _makes me think harder_ about the right name.
