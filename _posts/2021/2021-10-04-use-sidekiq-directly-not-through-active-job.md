---
title: "Use Sidekiq Directly, Not Through Active Job"
description: "Active Job is great, but you might be missing out."
layout: article
category: ruby
image:
  base: '2021/use-sidekiq-directly-not-through-active-job'
  alt: "Silhouetted karate kick on the beach"
  credit: "Jason Briscoe"
  source: "https://unsplash.com/photos/HN_4K2diUWs"

---

If you build a web application you should minimize the amount of time spent responding to every user; a fast website means a happy user. One way of doing that is to run long-running, parallelisable, or potentially slow, work asynchronously outside of the immediate web request. This might be sending emails, scheduled cleanups, long running calculations, or anything that uses an external API.

[Active Job](https://guides.rubyonrails.org/active_job_basics.html) is the recommended way of enqueuing and running background work in Rails. It provides a wrapper around a bunch of [different adapter implementations](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html) of the concept. Each implementation utilises a different underlying technology and has its own pros and cons. Most of the implementations existed before [Active Job was released](https://guides.rubyonrails.org/4_2_release_notes.html#active-job) in Rails 4.2.

One of the most popular, battle-tested, and performant asynchronous frameworks is [Sidekiq](https://sidekiq.org), which is multi-threaded and utilises Redis for its queuing storage. It’s an open source library with two paid tiers for additional high-end features.


## Instead of…

…defining your jobs using Active Job:

```ruby
class DoThingsInBackgroundJob < ApplicationJob
  queue_as :default

  def perform(an_active_record_object)
    an_active_record_object.do_things
  end
end
```

## Use…

…Sidekiq directly:

```ruby
class DoThingsInBackgroundJob
  include Sidekiq::Worker
  Sidekiq_options queue: "default"

  def perform(id)
    an_active_record_object = ActiveRecordObject.find_by(id: id)
    an_active_record_object.do_things
  end
end
```


## Why?

You’re missing out on a number of advantages when you don’t use Sidekiq directly.

If you're doing _a lot_ of work in the background, enqueuing many small fast-running jobs—as is generally suggested—leads to a [2—20x performance improvement](https://github.com/mperham/sidekiq/wiki/Active-Job#performance) if you use Sidekiq directly. The level of improvement will be dependant on your specific setup.

If you are enqueing lots of jobs, you could use [Sidekiq’s bulk enqueing functionality](https://github.com/mperham/sidekiq/wiki/Bulk-Queueing). This is hard to do when using Sidekiq with Active Job.

There are, confusingly, multiple levels of retries in the event of a job failure. Active Job has its own retry mechanism, which once completed then passes down to Sidekiq’s own (seperate and different!) retry system. This is a tricky thing to debug when things go wrong.

Active Job allows passing in an Active Record object to the `#perform` method, which is then serialized to a text argument using [Global ID](https://github.com/rails/globalid). This saves doing the lookup yourself but it can raise errors if records are deleted before the job is pulled from the queue. This automatic serialization also makes the arguments to the Sidekiq jobs difficult to read in the web dashboard.

If you are concerned about locking yourself into Sidekiq as a dependancy without the wrapper of Active Job, don’t be. Although less rare than swapping your main database, you are still very unlikely change your queuing system to a similarly limited Active Job adapter.

If you _are_ replacing your asynchronous infrastructure you should expect a major migration project, rather than just switching out an adapter via a single configuration line.


## Why not?

When using Sidekiq directly you have to think more about what your job arguments should be and then perform object lookups yourself. Sidekiq only permits simple values as job arguments.

There’s no need to change all your existing jobs if you are already using Sidekiq through Active Job. You don't have to use one or the other, you can define and use both at the same time. This might be a little confusing to manage, but it isn’t a terrible solution. You can just use direct Sidekiq jobs when you need the improved performance and bulk-enqueing.

If your workload is light, or you are early on in your project, you might not need Sidekiq (or at least its Redis dependancy) at all.

[Good Job](https://github.com/bensheldon/good_job) and [Que](https://github.com/que-rb/que) (postgres only) or [Delayed Job](https://github.com/collectiveidea/delayed_job) (any SQL database) are well-regarded Active Job adapters. When using one of these options you don’t need to run an additional piece of database infrastructure.


#### Recommendation

If you're using Sidekiq in production you should buy a license for the Pro version. The [extra reliability](https://github.com/mperham/sidekiq/wiki/Reliability#using-super_fetch) so that jobs are not “lost” due to crashes is enough of a reason when in a production environment, but there are other additional features including job deletion (by job id and kind of job) and web dashboard enhancements.


#### Disclamer

I’m a massive fan and “Pro” customer of Sidekiq and have met [Mike](https://twitter.com/getajobmike) (its author) at a couple of Ruby conferences. That hasn't coloured my view of the library. Sidekiq has _always_ been terrific and worth every penny for how we use it at [work](https://coveragebook.com).
