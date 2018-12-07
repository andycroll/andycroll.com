---
title: Always Force Booleans to be True or False
description: “Well duh,” you say. “Think about nil,” I say.'
layout: article
category: ruby
image:
  base: '2018/always-force-booleans-to-be-true-or-false'
  alt: 'Lovehearts, be true'
  source: 'https://unsplash.com/photos/ohqX8M_z85E'
  credit: 'Obi Onyeador'
---

Migrations, in common with much of Rails, are ‘[sharp knives](https://rubyonrails.org/doctrine/#provide-sharp-knives)’ — easy to use, but potentially dangerous, and you can end up cutting yourself.

One way a migration can ‘cut’ you is by letting you make quick decisions about your database structure without considering the consequences. In this case we'll examine the case of `NULL` in a boolen field your SQL (converted to `nil` when you use it in Ruby).


## Instead of…

...allowing boolean values to be `NULL` in your database.

```ruby
class AddRecommendedIndexes < ActiveRecord::Migration[5.1]
  def change
    add_column :characters, :satisfied, :boolean
  end
end
```


## Always…

...use constraints in your database that prevent values that should be only `true` or `false` from being `NULL`.

```ruby
class AddRecommendedIndexes < ActiveRecord::Migration[5.1]
  def change
    add_column :characters, :satisfied, :boolean, default: false, null: false
  end
end
```


## But why?

This is a known issue called the tri-state problem. Ideally you don't want a boolean (which by definition should be `true` or `false`) to ever be `NULL` (or `nil` when it is converted from SQL to Ruby).

Although `nil` behaves a lot like `false`, in Ruby they are not quite the same. Having a third state that you can think of as “a bit like `false`” really complicates the logic of your application.

Having `NULL` values in your database means you have to consider how they should behave and also complicates your scopes.

If you think of `nil` as `false` you'd have to use scopes like:

```ruby
Character.where(satisfied: false).or(Character.where(satisfied: nil))
Character.where.not(satisfied: true)
```

Which is much more confusing than:

```ruby
Character.where(satisfied: false)
```


### Why not?

If you’re starting from scratch, just do this.

If you already have this issue — and heaven knows I’ve fallen into the trap — you will have to put together a careful migration strategy.

When changing/adding columns or default values to an existing table many databases will lock the table while they write to every row. This means you’ll have to consider downtime or perhaps multiple smaller migrations to ensure you minimise the impact on your application.
