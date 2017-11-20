---
title: 'Choose UUIDs for model ids in Rails'
description: 'A little more complexity, a little more security'
layout: article
category: ruby
image:
  base: '2017/choose-uuids-for-model-ids-in-rails'
  alt: 'Rainbow UUIDs'
---

Ruby on Rails has had the [ability](https://github.com/rails/rails/pull/21762) to use UUIDs ([Universally Unique IDentifiers](https://en.wikipedia.org/wiki/Universally_unique_identifier)) for ActiveRecord models since version 5.0.

These are a native column type in PostgreSQL, there's more details on native Postgres types in the [Rails Guides](http://guides.rubyonrails.org/active_record_postgresql.html).

## Instead of…

…using Rails default incrementing integer IDs.


## Use…

…PostgreSQL’s UUID support.


### Enable extension

`bin/rails g migration enable_extension_for_uuid`

```ruby
class EnableExtensionForUuid < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
```

Change the default column type for primary keys

Configure your migration generator to set id: :uuid for new tables:


### `config/initializers/generators.rb`

```ruby
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
```


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

This is a case where you are making a choice toward a little more complexity, but for good reasons.

UUIDs allow you to assign model IDs in distributed systems without worrying about collisions. e.g. If you’re using a client-side JavaScript application.

With an incrementing integer ids you can see the growth of data from outside i.e. ID 5 is the fifth record created. With UUIDs no-one can guess the size of your database tables, which might be information you are keen to keep secret. You _can_ get round this by generating ‘public ids’ or 'slugs' for exposed URLs… but then, why not use a built-in tool.

From a security perspective using UUIDs prevents the situation where a malicious attacker could attempt to gain access to data based on guessing IDs in your URLs. UUIDs are extremely hard to guess.


### Why not?

If you’re using PostgreSQL, this is a straightforward change and has little performance cost. MySQL is a more complicated proposition.

ActiveRecord’s `first` and `last` scopes work in an unexpected way with UUID ids. You can no longer assume the ‘highest’ `id` is the most recent, which could be confusing for new developers to your codebase.

Transferring to non-integer IDs in a running production system is fiddly and fraught with opportunities to shoot yourself in the foot. This might be something to do for brand new projects unless you have a good reason.
