---
title: Using pluck can save a bunch of memory
description: ''
layout: article
category: ruby
image:
  base: '2018/using-pluck-can-save-a-bunch-of-memory'
  alt: 'Guitarist'
  source: 'https://unsplash.com/photos/DUrdHDn81mk'
  credit: 'Jacek Dylag'
---

Active Record models are incredibly flexible and provide a very large amount of functionality. One consequence of providing this large API of methods is that each individual Active Record object takes up a lot of space when loaded into memory.

If you only need to use a single field on an Active Record model, for example, the `id`s, then Rails has your back.

## Instead of…

…iterating over objects fully loaded into memory.

```ruby
Book.paperbacks.map { |book| book.title }
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
Book.paperbacks.map(&:title)
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
```


## Use…

…the `ActiveRelation#pluck` method to pull the required fields directly from the database.

```ruby
Book.paperbacks.pluck(:title)
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
```


## But why?

This is about speed and efficient memory usage.

The problem of Active Record models taking up a lot of memory becomes particularly painful if you're operating over large collections. In the first example, each row from the database is transformed into an object and yet we're only using a single field. All the extra functionality that a model has—and Rails prepares for you in memory—is unneeded.

Only loading the fields that you need means your application will run faster and use less memory.


### Why not?

The `#pluck` method returns only the values you request in a plain Ruby array—no methods are loaded from your model.

If you do need the actual Active Record object or need to update the model at some point after using `#pluck`, you’re out of luck.

You might also consider using a `select` clause in your scope, which would provide you with a full Active Record model rather than a plain array, _but_ only with the fields you request. This is still nowhere near as memory efficient as using `#pluck`.

```ruby
Book.paperbacks.select(:title).map { |book| book.title }
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
```
