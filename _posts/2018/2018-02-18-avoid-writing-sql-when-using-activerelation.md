---
title: 'Avoid Writing SQL When Using ActiveRelation'
description: 'It's fine, but prefer not to if you can.'
layout: article
category: ruby
image:
  base: '2018/avoid-writing-sql-when-using-activerelation'
  alt: 'Coding SQL'
  source: 'https://unsplash.com/photos/fPkvU7RDmCo'
  credit: 'Caspar Rubin'
---

ActiveRelation, which powers the searching and querying engine of ActiveRecord, is a powerful and flexible tool.


## Instead of...

...writing literal SQL strings inside an ActiveRelation `#where` method.

```ruby
Person.where("name = #{ params[:name] } and hidden_at is null")
```


## Or...

...writing literal strings and using the Array method to sanitise data.

```ruby
Person.where('name = ? and hidden_at is null', params[:name])
```


## Use...

...the hash-style syntax.

```ruby
Person.where(name: params[:name], hidden_at: nil)
```


## Why?

All methods are valid. The first two versions, where you manually write SQL, was the _only_ way before ActiveRelation was merged into Rails (in version 3.0). However, the “hash style” gives you more flexibility and safety.

The first example is **very** dangerous. **Do not** use string interpolation in your queries. It opens you up to SQL injection attacks: where bad people from the Internet can try and run destructive/exciting statements against your database.

The second example is a better way to write “string style” `#where` methods. But you're still left to write SQL yourself.

I much prefer the final example, when you use the “hash style” syntax. This version is shorter, clearer and likely better highlighted in your editor. Code is made to be read more than written.

It also, as an extra convenience, results in the more specific and portable SQL.

```ruby
# SQL string version
> Person.where('name = ? and hidden_at is null', 'Andy').to_sql
=> "SELECT \"people\".* FROM \"people\" WHERE (name = 'Andy' and hidden_at is null)"

# Hash style version
> Person.where(name: 'Andy', hidden_at: nil).to_sql
=> "SELECT \"people\".* FROM \"people\" WHERE \"people\".\"name\" = 'Andy' AND \"people\".\"hidden_at\" IS NULL"
```

As you can see when the “hash style” syntax evaluates it includes the database table name. When passing strings to `#where` the SQL only includes the exact string you pass in, so no table names.


## Why not?

It could be argued that using the ActiveRelation hash syntax _also_ allows you to have statements that could be portable between database adapters. With string conditionals you can introduce dependancies on your database's particular flavour of SQL.

However this only really occur in more complex SQL examples. And no-one _really_ moves their database between Postgres and MySQL once they’re in production. Not unless they adore pain.

This is also a very simple example. There are times when you might need to use a pure string representation that is specific to your database, and that’s totally fine. But if there’s an option, why not build some flexibility and clarity into your scopes?
