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

Migrations, in common with much of Rails, are ‘[sharp knives](https://rubyonrails.org/doctrine/#provide-sharp-knives)’ — easy to use but potentially dangerous and you can cut yourself.

One way a migration can ‘cut’ you is by letting you make quick decisions about your database structure without considering the consequences!


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

...use constraints that prevent values from being `nil` that should be only `true` or `false`.

```ruby
class AddRecommendedIndexes < ActiveRecord::Migration[5.1]
  def change
    add_column :characters, :satisfied, :boolean, default: false, null: false
  end
end
```


## But why?

This is a known issue called the tri-state problem. Ideally you don't want a boolean (which by definition should be `true` or `false`) to ever equal `nil`.

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

If you already have this issue, and heaven knows I’ve done it, you will have to put together a careful migration strategy. This might also be true of adding these sorts of columns to existing tables, depending on your underlying database.

Setting defaults and constraints on existing tables to avoid downtime or long running migrations needs careful thought.
