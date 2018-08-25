---
title: Careful with present? when using ActiveRecord scopes
description: 'Mostly it’s fine, until your app goes boom.'
layout: article
category: ruby
image:
  base: '2018/careful-with-present-when-using-activerecord-scopes'
  alt: 'Stadtbibliothek, Stuttgart, Deutschland'
  source: 'https://unsplash.com/photos/PkbZahEG2Ng'
  credit: 'Tobias Fischer'
---

We’re trained when using Rails to use `#present?` all over the place. For example, you might use it before trying to loop through an array in a view.

However using `#present?` on models with large datasets can create unforeseen problems.


## Instead of…

...using `#present?` on an Active Relation (a uninstantiated scope on an Active Record class)

```ruby
books = Book.recently_released
if books.present?
  books.paperbacks.each { |book| puts book.title }
end
```


## Use…

...`#any?` or `#exists?`

```ruby
books = Book.recently_released
if books.any?
  books.paperbacks.each { |book| puts book.title }
end
```


## But why?

When you call `#present?` it instantiates the models in an array in memory before checking whether that array is empty or not. In most cases this will be fine but in extreme cases, say complex models, or a large dataset you might see large memory usage and slowdowns.

If you use `#any?` a different, simpler SQL command is run that doesn't build a large array of Active Record objects.

There’s also no penalty to using it if the records are already loaded.

As always with changes to how your application uses the database, you’ll definitely want to monitor how the changes affect the real-life performance characteristics of _your_ application.

You _could_ even monkey-patch the default behaviour of `#present?` on Active Relations in Rails by using the [`attendance` gem](https://github.com/schneems/attendance). This is a bit of a blunt instrument though and you’ll want to watch the performance of your app very closely if you take the plunge.


### Why not?

Using `#any?` _is_ an extra SQL query, and the performance of your app might not benefit from the change in approach.

Additionally the preloading of records might actually be more efficient if you then go on to use them.

A similar “fix” to that in the `attendance` gem, changing how `#present?` works on an Active Relation, has been [merged](https://github.com/rails/rails/pull/10539) and then [reverted](https://github.com/rails/rails/commit/2b763131eacaae5bff9ffb5015fbf367d594dc64) from Rails in favour of the existing behaviour. So there are definite performance subtleties to checking the presence of records.
