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

Active Record models are incredible flexible and provide a very large amount of flexibility. One of the consequences of providing this large API of methods is that each individual Active Record object takes up a lot of space when loaded into memory.

If you only use a single field, or just need the `id`s, Rails has your back.

## Instead of…

...iterating over objects fully loaded into memory.

```ruby
Book.paperbacks.map { |book| book.title }
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
Book.paperbacks.map(&:title)
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
```


## Use…

...the `ActiveRelation#pluck` method to pull the fields directly from the database.

```ruby
Book.paperbacks.pluck(:title)
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
```


## But why?

This is about speed and efficient memory usage.

Active Record models can take up a lot of memory, particularly true if you're operating over large collections. Each row from the database is transformed into an object and then in the first example we're just picking a single field, you can see that all the extra functionality that a model has (and Rails prepares for you in memory) is wasted.

Just picking the fields you need means your application will run faster and use less memory.


### Why not?

The `#pluck` method returns only the values you request in a plain Ruby array, no methods are loaded from your model.

If you actually need the actual Active Record model or need to update at some point after using `#pluck` you’re out of luck.

You might also consider using a `select` clause in your scope, although this is still not as memory efficient as using `#pluck`.

```ruby
Book.paperbacks.select(:title).map { |book| book.title }
#=> ["Eloquent Ruby", "Sapiens", "Agile Web Development With Rails"]
```
