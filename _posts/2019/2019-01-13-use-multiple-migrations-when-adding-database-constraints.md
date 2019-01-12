---
title: Use Multiple Migrations When Adding Database Constraints
description: You need to avoid a long table rebuild and a write-lock
layout: article
category: ruby
image:
  base: '2018/use-multiple-migrations-when-adding-database-constraints'
  alt: 'Locks'
  source: 'https://unsplash.com/photos/8_NI1WTqCGY'
  credit: 'Marcos Mayer'
---

Adding constraints to your application at the database layer is a good idea as it provides an extra layer of quality control on top of the data powering your application.

One way to do that is to add default values or constraints (like making sure a field can’t be blank), this is easy to do with Rails’ migrations. But beware...


## Instead of…

…adding a column and stipulating a default non-null value all in one go.

```ruby
class AddComposerToSongs < ActiveRecord::Migration[5.2]
  def change
    add_column :songs, :composer, :string, default: "Lin-Manuel Miranda", null: false
  end
end
```


## Use…

…a multiple migration strategy to add a field with a constraint to your databases


### Add a column

```ruby
class AddComposerToSongs < ActiveRecord::Migration[5.2]
  def change
    add_column :songs, :composer, :string
  end
end
```


### Deploy code that sets default, in Ruby

```ruby
class Song < ApplicationRecord
  before_save :set_default_composer

  def set_default_composer
    self.composer = "Lin-Manuel Miranda" if composer.nil?
  end
end
```


### Update records with nil values

```ruby
Song.where(composer: nil).update_all(composer: "Lin-Manuel Miranda")
```


### Change the column to have a constraint

```ruby
class AddRecommendedIndexes < ActiveRecord::Migration[5.1]
  def change
    change_column :songs, :composer, :string, default: "Lin-Manuel Miranda", null: false
  end
end
```

…and then you can delete the Ruby code that sets a default.


## But why?

If you take the “all in one” approach you run the risk of significant downtime for your application.

If you set `null: false` in your migration Active Record will rewrite the whole table, locking it whilst doing so. This may take a significant amount of time, depending on how much data you already have stored. Locking your database’s table will likely cause write timeouts for any users trying to write to your database at the same time.

The multi-stage deployment is a bit of a pain, but it enables you to keep the application available for your users during any migration of data tables.


### Why not?

If you’re starting a new app or have a very limited dataset.

You might get away with a whole table rewrite and write-lock if you have low amounts of traffic writing to the database. But you would be _getting away with it_. Chances are you’re going to have some downtime.

If you don't mind putting your application into maintenance mode, where users are blocked from using the site, you could run the migration with downtime.
