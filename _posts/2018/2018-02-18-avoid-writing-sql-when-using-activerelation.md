---
title: 'Avoid Writing SQL When Using ActiveRelation'
description: 'Why write SQL when you can write Ruby?'
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

...writing literal SQL strings with direct string interpolation inside an ActiveRelation `#where` method.

```ruby
Person.where("name = #{ params[:name] } AND hidden_at IS NULL")
```


## Or...

...writing literal SQL strings and using the ‘array style’ to safely interpolate user input.

```ruby
Person.where('name = ? AND hidden_at IS NULL', params[:name])
```


## Use...

...the ‘hash style’ syntax.

```ruby
Person.where(name: params[:name], hidden_at: nil)
```


## Why?

The first two versions, where you manually write SQL, were the _only_ way to specify database queries before ActiveRelation was merged into Rails (in version 3.0). However, the “hash style” gives you more flexibility and safety.

The first example is **very** dangerous. It uses direct interpolation of the string, in this case from user-passed parameters. **Do not use this style**. It opens you up to SQL injection attacks: where bad people from the Internet can try and run destructive/exciting statements against your database.

The second example, the ‘array style’, does sanitize passed data, so is a better way to write “string style” `#where` methods. However you're still left to write SQL yourself. Why do it when `ActiveRelation` is more than happy to generate perfect SQL while you keep writing delightful Ruby.

The final example, with the “hash style” syntax, is shorter, clearer, and likely better highlighted in your editor. Code is made to be read more than written.

When passing strings to `#where` the resulting SQL includes the exact string you pass in, so no table names _and_ all your typos.

```ruby
# Hash style
> Person.where(name: 'Andy', hidden_at: nil).to_sql
=> "SELECT \"people\".* FROM \"people\" WHERE \"people\".\"name\" = 'Andy' AND \"people\".\"hidden_at\" IS NULL"

# String style
> Person.where('name = ? and hidden_at is null', 'Andy').to_sql
=> "SELECT \"people\".* FROM \"people\" WHERE (name = 'Andy' and hidden_at is null)"
```

When the “hash style” syntax evaluates, it includes the database table names and the SQL is more precise, which can help reduce errors when joining and querying multiple models.

Using the hash style also provides extra convenience in that the SQL generated is portable between database adapters.


## Why not?

When using string conditionals you can introduce dependencies on your database's particular flavour of SQL. However this is only a problem when you use more esoteric database-specific SQL, perhaps search or geographic queries. Straightforward SQL `SELECT` syntax as seen in the above examples is not an issue.

Also, no-one _really_ moves their database between PostgreSQL and MySQL once they’re in production. Not unless they adore pain.

This is also a very simple example. There are times when you might need to use a string argument to `#where` that is specific to your database, and that’s totally fine. But if there’s an option, why not build some flexibility and clarity into your scopes?
