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

It is alleged that Ruby is slow. However, whether you're using Ruby, Elixir or Go the 'benchmarked' speed of a language is irrelevant if you’re building a web application that eventually hits an unoptimised database.


## Instead of…

...having your database do more work than it needs to.


## Use…

...database indexes when you query on foreign keys and for queries over multiple fields.

```ruby
class AddRecommendedIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :model_with_foreign_key, :user_id
    add_index :polymorphic_model, [:polymorphic_id, :polymorphic_type]
    add_index :model_found_by_other_field, :slug
    add_index :model_with_complex_queries, [:slug, :title, :score, :updated_at]
  end
end
```


## But why?

Nobody has ever used a website and thought: “I wish this site loaded slower”.

Modern SQL databases can be incredibly quick and powerful, but you still need to do some tuning.

Without indexes on often-queried fields on tables, the database does a sequential scan (or in the case of more complex queries, multiple scans). A sequential scan can take many times longer to execute as you add more records. While there might be less difference on tens of records, scans over thousands of records without an index can be very slow.

I like to use a heuristic that any individual SQL query in production should take between 1-10ms. If it's taking longer than that, you should find out why.

If you care about the performance of your site for your users and your language of choice, then you should equally be thinking about the underlying performance of your database.


## Why not?

While I am advocating improving and optimising database performance, you shouldn’t just add indexes blindly.

Your database pays a performance penalty for every index you have on a table. When you _write_ to a table with indexes the database must take time to update each one.

If the broader usage patterns of your application are write-heavy rather than read-heavy you should definitely be thinking carefully about adding any indexes, they may cause more problems than they solve.

Additionally, When trying to improve the performance of your site you must _actually measure it_. Use a monitoring tool like [Skylight](https://skylight.io), [New Relic](https://newrelic.com), [AppSignal](https://appsignal.com) or [Scout](https://scoutapp.com). This way you’ll know which parts of your site performance to actually work on. It might not even be the database that is causing issues.
