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

We often have to enqueue lots of the same jobs at the same time. Perhaps a data migration for all of one kind of object? Or a data processing step that will run faster if it's parallelised?

Our focus is often on the potentially large queues or the elapsed time it takes to churn through all the work. There is another task that we have to consider. Enqueing all that work in the first place.


## Instead of…

…looping through lots of Active Record objects:

```ruby
Customer.all.each do |customer|
  DeliverEmailJob.perform_async(customer)
end
```

...or better, if you have more than a few hundred jobs to enqueue:

```ruby
Customer.find_in_batches do |customer|
  DeliverEmailJob.perform_async(customer)
end
```


## Use…

…Sidekiq directly:

```ruby
ids = Customer.all.pluck(:id)
array_of_args = ids.map { |x| [x] }
DeliverEmailJob.perform_bulk(array_of_args)
```

Or, if using a Sidekiq version before 6.3.0:

```ruby
ids = Customer.all.pluck(:id)
array_of_args = ids.map { |x| [x] }
Sidekiq::Client.push_bulk('class' => DeliverEmailJob, 'args' => array_of_args)
```


## Why?

Primarily this minimizes round trips to Redis. Instead of making an individual call for each enqueing action across the network, you make _one_. This is a big deal even when using code as well optimised for speed as Redis.

This can also have the benefit (on top of passing scaler `id`s to jobs) of minimising the amount of memory used. By `pluck`ing `id`s rather than looping over arrays of Active Record models you are simply dealing with less complex objects which take up less memory.

The author of Sidekiq [recommends limiting to 1000 jobs](https://github.com/mperham/sidekiq/wiki/Bulk-Queueing) per bulk enqueue, that's the default in the `perform_bulk` method. Even then you are saving the time of 999 round trips to Redis.


## Why not?

Typically the tasks that require many concurrent jobs are not enqueued during a web request from a customer, so you're typically doing this in a way that doesn't impact the response times of your customers directly.

The pre-6.3.0 version of the bulk API is a little fiddly and leaves space for you to make a mess of the method. I'd recommend updating to the latest version and using the `.perform_bulk` syntax.

Also, this functionality requires that you use Sidekiq directly and not via Active Job. I have previously suggested [plenty of reasons to use Sidekiq directly](/ruby/use-sidekiq-directly-not-through-active-job/).


#### Recommendation

If you're using Sidekiq in production you should buy a license for the Pro version. The [extra reliability](https://github.com/mperham/sidekiq/wiki/Reliability#using-super_fetch) so that jobs are not “lost” due to crashes is enough of a reason when in a production environment, but there are other additional features including job deletion (by job id and kind of job) and web dashboard enhancements.


#### Disclamer

I’m a massive fan and “Pro” customer of Sidekiq and have met [Mike](https://twitter.com/getajobmike) (its author) at a couple of Ruby conferences. That hasn't coloured my view of the library. Sidekiq has _always_ been terrific and worth every penny for how we use it at [work](https://coveragebook.com).
