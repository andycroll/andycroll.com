---
title: "Enqueue Jobs Quickly with Sidekiq’s Bulk Features"
description: "From thousands of network calls, to one."
layout: article
category: ruby
image:
  base: '2022/enqueue-jobs-quickly-with-sidekiq-bulk'
  alt: "Martial Arts on the beach"
  credit: "Thao Le Hoang"
  source: "https://unsplash.com/photos/Xl-ilWBKJNk"

---

We often have to enqueue lots of the same type of job at the same time. Perhaps it’s a data migration for all of one kind of object, or a data processing step that‘ll run faster if it's parallelised.

Our focus is often on the potentially large queues or the time it will take to churn through all the work. But there’s another part of this that we have to consider: enqueuing all that work in the first place.


## Instead of…

…looping through lots of Active Record objects:

```ruby
Customer.all.each do |customer|
  DeliverEmailJob.perform_async(customer)
end
```

...or better, using `find_in_batches`, if you have more than a few hundred jobs to enqueue:

```ruby
Customer.find_in_batches do |customer|
  DeliverEmailJob.perform_async(customer)
end
```


## Use…

…Sidekiq directly:

```ruby
Customer.all.in_batches do |relation|
  array_of_args = relation.ids.map { |x| [x] }
  DeliverEmailJob.perform_bulk(array_of_args)
end
```

Or, if using a Sidekiq version before 6.3.0:

```ruby
Customer.all.in_batches do |relation|
  array_of_args = relation.ids.map { |x| [x] }
  Sidekiq::Client.push_bulk('class' => DeliverEmailJob, 'args' => array_of_args)
end
```


## Why?

This minimises round trips to Redis. Instead of making an individual call for each enqueing action across the network, you make _one_. This is a big deal even when using tools as well optimised for speed as Redis.

This can also have the benefit of minimising the amount of memory used. By `pluck`ing `id`s, or using the `ids` method as shown, rather than looping over arrays of Active Record models, you are using less complex Ruby objects and thus less memory.

The author of Sidekiq [recommends a limit of 1,000 jobs](https://github.com/mperham/sidekiq/wiki/Bulk-Queueing) per bulk enqueue and that's the default in the `perform_bulk` method. Even then you are saving the time of 999 round trips to Redis.


## Why not?

It is more usual that enqueuing lots of jobs does not occur during a web request from a customer. Thus your customers are not necessarily suffering through the much slower approach. However if you are enqueuing jobs on the command line or in scheduled tasks it’s now _your time_ you are wasting!

The pre-6.3.0 version of the bulk API is a little fiddly and leaves space for you to make a mess of the method. I'd recommend updating to the latest version and using the `.perform_bulk` syntax.

Also, this functionality requires that you use Sidekiq directly and not via Active Job. I have previously suggested [plenty of reasons to use Sidekiq directly](/ruby/use-sidekiq-directly-not-through-active-job/).


#### Recommendation

If you're using Sidekiq in production you should buy a license for the Pro version. The [extra reliability](https://github.com/mperham/sidekiq/wiki/Reliability#using-super_fetch) so that jobs are not “lost” due to crashes is enough of a reason when in a production environment, but there are other additional features including job deletion (by job id and kind of job) and web dashboard enhancements.


#### Disclamer

I’m a massive fan and “Pro” customer of Sidekiq and have met [Mike](https://twitter.com/getajobmike) (its author) at a couple of Ruby conferences. That hasn't coloured my view of the library. Sidekiq has _always_ been terrific and worth every penny for how we use it at [work](https://coveragebook.com).
