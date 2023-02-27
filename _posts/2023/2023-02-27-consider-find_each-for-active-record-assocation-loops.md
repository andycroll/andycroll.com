---
title: "Consider find_each for looping through Active Record associations"
description: "Rarely used, but protects you against foot shooting"
layout: article
category: ruby
image:
  base: '2023/consider-find_each-for-looping-through-active-record-associations'
  alt: "Light loops"
  credit: "Nareeta Martin"
  source: "https://unsplash.com/photos/za2gMSfLmzU"

---

The standard method for enumerating through groups of objects, both through arrays in Ruby and through Active Record models in Rails, is `each`.

However, if you are looping over a large amount of data, perhaps all the records for a model in order to backfill data, you can encounter severe memory and speed issues, both with loading and processing large volumes of records.

You should consider the functionality provided by [Active Record’s Batches](https://api.rubyonrails.org/classes/ActiveRecord/Batches.html). We’ll demonstrate using `find_each`.


## Instead of…

…looping through lots of Active Record objects using `.each`:

```ruby
post.comments.each do |comment|
  # Do stuff with each comment: enqueue a job
end
```


## Use…

…`.find_each` to more efficiently load records from the database:

```ruby
post.comments.find_each do |comment|
  # Do stuff with each comment: enqueue a job
end
```


## Why?

Using `each` makes _one_ SQL call to the database and tries to load the entire set of objects into memory and then loop over them. It’s the same as if you'd called `post.comments.all.each` instead in the first example.

This is a problem in two dimensions. First, the database query may take a long time to execute or may time out. Second, when (or if) it does return data, there’s likely to be significant memory usage as it loads all the records into memory in order to loop over them. 

Using `.find_each` makes a series of more efficient SQL queries (with a bunch of sensible defaults) to retrieve records from the database, which is often a lot more efficient than loading all records into memory at once.


## Why not?

If you need to see the records in a particular order, `.find_each` doesn't support that.

If you need to modify the records in place, this sort of looping isn’t ideal. For example, if you’re running an `#update` on each record, you’ll be executing _a lot_ of queries. Instead consider more appropriate methods for bulk updating methods, such as `#update_all`.

Don't use either the each or find_each version to generate view code. Having a view large collection to loop through in view code, given you don't know how many records you’ll have, is a recipe for slow pages and poor user experience. Consider [using pagination](/ruby/do-not-use-all-without-pagination-or-limit) instead.

The Rails guides suggest `find_each` is only needed for processing a large number of records that wouldn't fit in memory all at once. If you only need to loop over fewer than one thousand records the regular methods are fine/recommended.

At large scale you’ll need to use even more advanced techniques and you’ll have to move beyond long running loops. Perhaps you want to reduce a high volume of read/write operations on your database or you want to cut down execution time from minutes to hours!