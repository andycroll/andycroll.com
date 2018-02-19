---
title: 'Check Your Database Indexes For ActiveRecord Scopes'
description: 'Database indexes are always more important than you think'
layout: article
category: ruby
image:
  base: '2018/check-your-database-indexes-for-activerecord-scopes'
  alt: 'Construction Site'
  source: 'https://unsplash.com/photos/8Gg2Ne_uTcM'
  credit: '贝莉儿 NG'
---

It is alleged that Ruby is slow, but it doesn’t matter if you're using Elixir, Go or Ruby if you’re building a web application that eventually hits an unoptimised database. Which you probably are if you’re reading this.

## Instead of…

...having your database do more work than it needs to.


## Use…

...database indexes when you query on foreign keys and queries over multiple fields.

```ruby
class AddRecommendedIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :model, :user_id
    add_index :polymorphic_model, [:polymorphic_id, :polymorphic_type]
    add_index :model_with_a_user_facing_slug, :slug
    add_index :model_shown_sorted_by_recent_changes, :updated_at
    add_index :model_with_complex_queries, :updated_at
  end
end
```

_This is just some possible simple reasons._

## But why?

Nobody has ever used a website and thought, “you know, I wish this site loaded slower”.

Modern SQL databases can be incredibly quick and powerful, but you still need to do some tuning.

Without indexes on often-queried fields on tables, the database does a sequential scan (or in the case of more complex queries, multiple scans). A sequential scan can take many times longer to execute as you add more records. While there might be less difference on tens of records, scans over thousands of records without an index can be very slow.

Ideally in production systems you want to be looking at any individual SQL query happening in the request to be taking between 1-10ms. If it's taking longer you want to understand why.

If you aren't thinking about your underlying SQL performance, you aren’t thinking about performance.


## Why not?

It's important to note here that while I’m advocating adding indexes to fields frequently used to do SQL-based lookups, I am advocating blind.

It is important to actually measure your site’s performance using a tool like [Skylight](https://skylight.io), [New Relic](https://newrelic.com), [AppSignal](https://appsignal.com) or [Scout](https://scoutapp.com). This way you’ll know which parts of your site performance to actually work on.

You pay a performance penalty for every index you have on a table. Whenever you _write_ to a table with indexes the database must take time to update them.

If the broader usage patterns of your application are write heavy rather than read heavy you should definitely be thinking carefully about indexes, but again measure using some kind of performance monitoring tool.
