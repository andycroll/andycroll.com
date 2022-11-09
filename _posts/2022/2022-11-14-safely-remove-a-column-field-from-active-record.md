---
title: "Safely Remove a Column from an Active Record Model"
description: "Avoid migration-related errors when you’re tidying your database"
layout: article
category: ruby
image:
  base: "2022/safely-remove-a-column-field-from-active-record"
  alt: "A partial column against flat background"
  credit: "ANIRUDH"
  source: "https://unsplash.com/photos/jtiQCAAzLYY"
---

Adding and deploying new columns to an existing Active Record model is often straightforward. Typically the first deployment runs your migrations, and then new code that uses the recently-added database column is released afterward.

However, removing a column tends to cause problems. Active Record caches database columns when it spins up a Rails application. When the column is removed from the database table it raises exceptions until your app reboots or redeploys.

It's also worth a multi-step strategy when removing columns in your database.


## Use...

...this multi-step strategy:

First tell Active Record to ignore the column. This stops the rest of your application being able to reference this column.

```ruby
class Thing < ApplicationRecord
  # ...
  self.ignored_columns = ["old_column"]
  # ...
end
```

You can use your test suite to find places you might be still using the column in your application. Once your tests are passing, deploy this code.

Then, create the migration to remove the actual database column.

```ruby
class RemoveOldColumnFromThings < ActiveRecord::Migration[7.0]
  def change
    remove_column :things, :old_column
  end
end
```

Then deploy, migrating the column into oblivion.

After that, in a final change, remove the `ignored_columns` line you added for the initial step and deploy once more.


## Why?

In a larger team or application, having stable and predictable ways to change your database, without causing errors or downtime, is very important.

Rails gives you built-in tools to change your database, but doing it in the production environment of a busy application often requires greater care.

To a certain extent having good test coverage and a healthy process for deploying multiple times a day is a prerequisite of this method given that this “simple” column removal requires three seperate deployments.


### There's a gem for that!

Look into the [`strong_migrations` gem](https://github.com/ankane/strong_migrations) that was initially developed at InstaCart.

It blocks potentially dangerous migrations and warns you, with lovely helpful instructions, if you code might block reads or writes for more than a few seconds or (like in this case) has a good chance of causing application errors.


## Why not?

In projects with low traffic, or during the early stages of a Rails application, this isn't strictly necessary. In cases like this, you're likely fine putting up with a handful of errors on deploy.

Still, this is a good habit to begin to exercise as early as possible!
