---
title: 'Choose UUIDs for model IDs in Rails'
description: 'A little more complexity, a little more security'
layout: article
category: ruby
image:
  base: '2017/choose-uuids-for-model-ids-in-rails'
  alt: 'Rainbow UUIDs'
---

A [universally unique identifier](https://en.wikipedia.org/wiki/Universally_unique_identifier) (UUID) is a 128-bit number used to identify information in computer systems. Sometimes it is referred to as a ‘globally unique identifier’.

These are a native column type in PostgreSQL. You can find more details on native Postgres types in the [Rails Guides](https://guides.rubyonrails.org/active_record_postgresql.html).


## Instead of…

…using Rails’ default incrementing integer `id`.


## Use…

…PostgreSQL’s UUID support. Ruby on Rails has had the [ability](https://github.com/rails/rails/pull/21762) to use UUIDs as the `id` for ActiveRecord models since version 5.0.


### Enable the PostgreSQL extension

`bin/rails g migration enable_extension_for_uuid`

```ruby
class EnableExtensionForUuid < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
```


### Create `config/initializers/generators.rb`

```ruby
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
```

This changes the default column type for primary keys, configuring your migration generator to set `id: :uuid` for new tables.


### In future migrations

You'll have to use `type: :uuid` when creating relations.

```ruby
class AddNewTable < ActiveRecord::Migration[5.1]
  def change
    create_table :related_model do |t|
      t.references :other, type: :uuid, index: true
    end
  end
end
```


## But why?

Using UUIDs as the `id` in your Rails models instead of incrementing integers helps you avoid collisions. The UUIDs are _globally_ unique meaning you can know that different models cannot possibly have the same `id` and you can even assign them client-side or in other systems.

With an incrementing integer `id` the size of your data can be inferred from the outside i.e. `id` 5 is the fifth record created. With UUIDs no-one can guess the size of your database tables, which might be information you are keen to keep secret. You _can_ get round this by generating ‘public ids’ or 'slugs' for exposed URLs… but then, why not use a built-in tool?

From a security perspective, using UUIDs prevents the situation where a malicious attacker could attempt to gain access to data by guessing a model `id` in your URLs. UUIDs are extremely hard to guess.

This _is_ a case where you are making a choice toward a little more complexity, but for good reasons.


## Why not?

If you’re using PostgreSQL this is a straightforward change and has little performance cost. MySQL is a more complicated proposition and I wouldn't bother.

ActiveRecord’s `first` and `last` scopes work in an unexpected way with UUID ids. You can no longer assume the ‘highest’ `id` is the most recent, which could be confusing for new developers to your codebase.

Using UUIDs is a good idea in brand new projects, but it might be wise to avoid transferring to UUIDs in a running production system unless you have a good reason to do so.


-----

Translated into Japanese [here](https://techracho.bpsinc.jp/hachi8833/2018_01_04/50565)
