---
title: "Really, Really, Really Don’t Interpolate Strings into Active Record Methods"
description: "It’s risky to expose your database to SQL Injections"
layout: article
category: ruby
image:
  base: '2023/really-really-really-do-not-interpolate-strings-into-active-record-methods'
  alt: "Tables in a courtyard"
  credit: "Dimitra Peppa"
  source: "https://unsplash.com/photos/-abBaVOMsBk"

---

Protecting your application against malicious users is one of your key responsibilites as a developer. The built-in security provided by a well-maintained framework, such as Rails, is an excellent reason to use one.

This is particularly true of the protection afforded within Active Record for sanitizing user input before it is written to your database. However there are ways to pass strings directly to Active Record scopes when you need to, but that power should be used _very_ sparingly and carefully.


## Instead of…

…using strings in any arguments sent to Active Record:

```ruby
User.delete_by("id = #{params[:id]}")
User.where("email = #{params[:email]}")
```


## Use…

…hash-based variants of the same methods:

```ruby
User.delete_by(id: params[:id])
User.where(email: params[:email])
```


## Why?

Rails is a [sharp knife](https://rubyonrails.org/doctrine#provide-sharp-knives). While it does a lot for developers, it also allows you the flexibility to bend the framework to your use case. In this case: passing strings to Active Record methods.

You’re unlikely to reach for string interpolation in the specific examples above given the breadth of support for straightforward database actions in Active Record, but when you have a long and complex SQL query, it is easy to forget to sanitize any user input.

Using strings with interpolated (and user-provided) parameters opens you up to SQL injection attacks.

```ruby
# user-provided parameter
params[:id] = "1) OR 1=1--"
User.delete_by("id = #{params[:id]}")
#=> User Delete All (4.2ms)  DELETE FROM "users" WHERE (id = 1) OR 1=1--)
```

The `1=1` part of the user-provided string above is _always_ true and so would trigger an SQL command that drops every user in your database. Not good.

Interpolating values directly into the arguments can lead to unpredictable behaviour and results, not just malicious destructive examples like the one above. For example, you might leak information you hadn't intended to.

```ruby
params[:email] == 
User.where("email = #{params[:email]}")
```

Finally, the string-based arguments make your code harder to read and understand. The syntax for the hash-based approach is much easier to understand.


## Why not?

These are contrived examples. And yet real weaknesses.

If you’re unable to use the hash-style for the specific query you require and you really, really, _really,_ know what you’re doing, then use the string-based arguments. But be careful.