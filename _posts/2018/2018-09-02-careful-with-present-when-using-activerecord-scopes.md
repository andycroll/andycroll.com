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

When using Rails, `#present?` is available on all Ruby objects. Therefore, we tend to use it in many places. For example, you might use it in a view to check if an array has some elements before trying to loop through it and display some data.

However, using `#present?` on scopes can create unforeseen performance problems.


## Instead of…

…using `#present?` on an Active Relation (a scope on an Active Record class)

```ruby
books = Book.recently_released
if books.present?
  books.paperbacks.each { |book| puts book.title }
end
```


## Use…

…`#any?` or `#exists?`

```ruby
books = Book.recently_released
if books.any?
  books.paperbacks.each { |book| puts book.title }
end
```


## But why?

When you call `#present?` on an Active Relation it loads all of the Active Record objects in that scope into an array in memory before checking whether that (possibly very large) array is empty or not.

In most cases this will be fine but in extreme cases, say complex models or when using a large dataset, you might see very high memory usage and slow performance. This happens whether you then use those objects or not.

If you use `#any?`, a different, simpler SQL command is run that doesn't build an array at all. Generally the additional SQL call is a smaller performance impact than loading all the objects into memory.

If the relation has already been used, meaning the objects are loaded into memory, there’s no penalty to using `#present?` as it uses the existing array rather than loading a new one.

As always with changes to how your application uses the database, you’ll definitely want to monitor how the changes affect the real-life performance characteristics of _your_ application. You need to make sure the extra SQL request from the call to `#any?` isn't a worse performing solution than using `#present?` for your data.

You _could_ even monkey-patch the default behaviour of `#present?` on Active Relations in Rails, to always use `#any?`, by using the [`attendance` gem](https://github.com/schneems/attendance) to save yourself hunting down every use of `#present?`. This is a bit of a blunt instrument though and you’ll want to watch the performance of your app very closely if you take this blanket approach.


### Why not?

When you use `#any?` you are making an extra SQL query and the performance of your app might not benefit from the change in approach. The preloading of records might be more efficient if you then go on to use them.

A similar “fix” to that offered in the `attendance` gem—changing how `#present?` works on an Active Relation—was [merged](https://github.com/rails/rails/pull/10539) and then [reverted](https://github.com/rails/rails/commit/2b763131eacaae5bff9ffb5015fbf367d594dc64) from Rails in favour of the existing behaviour, where you have to be more specific and choose to use `#any?`.

This shows that there are definite performance subtleties in this technique. What might seem to be an obvious performance improvement may not be for your application.
