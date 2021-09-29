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

If you build a web application you should minimize the amount of time spent responding to every user; a fast website means a happy user. One way of doing that is to run long-running, parallelisable, or potentially slow, work asynchronously outside of the immediate web request. This might be sending emails, scheduled cleanups, long running calculations or anything that uses an external API.

[Active Job](https://guides.rubyonrails.org/active_job_basics.html) is the recommended way of enqueuing and running background work in Rails. It provides a wrapper around a bunch of [different implementations](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html) of the concept. Each implementation utilises a different underlying technology and has it's own pros and cons. Most of the implementations existed before [Active Job was released](https://guides.rubyonrails.org/4_2_release_notes.html#active-job) in Rails 4.2.

One of the most popular, battle-tested and performant asynchronous frameworks is [Sidekiq](https://sidekiq.org), which is multi-threaded and utilises Redis for it's queuing storage. It’s an open source library with two paid tiers for additional high-end features.

Disclaimer: I'm a massive fan and “Pro” customer of Sidekiq and have met [Mike](https://twitter.com/getajobmike) (it's author) a little at a couple of Ruby conferences. That hasn't coloured my view of the library, it has _always_ been terrific and is worth every penny for our use at [work](https://coveragebook.com).


## Instead of…

…defining your jobs using Active Job:

```ruby
class DoThingsInBackgroundJob < ApplicationJob
  queue_as :default

  def peform(an_active_record_object)
    an_active_record_object.do_things
  end
end
```

## Use…

…Sidekiq directly:

```ruby
class DoThingsInBackgroundJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def peform(id)
    an_active_record_object = ActiveRecordObject.find_by(id: id)
    an_active_record_object.do_things
  end
end
```


## Why?

Active Job is a solid super-set of Sidekiq's functionality, but you’re missing out on a number of advantages if you use it without.

If you're doing _a lot_ of work in the background, enqueuing many small fast-running jobs (as is generally suggested) there is a [2—20x performance improvement](https://github.com/mperham/sidekiq/wiki/Active-Job#performance) if you use Sidekiq directly. This improvement will be dependant on your specific setup.

If you are enqueing lots of jobs, you could be using [Sidekiq’s bulk enqueing functionality](https://github.com/mperham/sidekiq/wiki/Bulk-Queueing), this is hard to do performantly when using sidekiq with ActiveJob.

When using Sidekiq via Active Job there are, confusingly, multiple levels of retries in the event of a job failure. Active Job has it's own retry mechanism, which once completed then passes down to Sidekiq’s own (seperate and different!) retry system. This is a strange thing to debug when things go wrong.

When using Active Job and passing in an Active Record object, you rely on the object being serialized to a text argument using [Global ID](https://github.com/rails/globalid). This does save doing the lookup yourself (as you can see in the Active Job example) but it raises errors if records can be deleted (or even not created!) before the job is pulled form the queue. It also makes the arguments of the jobs a bit ugly in the web dashboard.

There’s no real harm to “locking yourself into” a specific job framework. You are unlikely to swap in future for another queuing system with similar (intentionally) limited functionality availible in Active Job. In a real life situation where your asyncronous infrastructure is struggling, you’d be assessing various solutions with more functionality and planning for a major migration project.

If you're using Sidekiq in prduction you should buy a license for the Pro version. The [extra reliability](https://github.com/mperham/sidekiq/wiki/Reliability#using-super_fetch) so that jobs are not “lost” due to crashes is enough of a reason when in a production environment, but there are other additional features including job deletion (by job id and kind of job) and web dashboard enhancements.


## Why not?

When using Sidekiq directly you have to think more about your job arguments and perform object lookups yourself, Sidekiq only permits simple values as job arguments.

You can use Active Job-style _and_ direct Sidekiq jobs onto the same queues at the same time because Active Job wraps Sidekiq. You don't have to switch everything, you can use both styles in the same application.

There is the deeper question as to why use Sidekiq at all if your workload is light, or you are early on in your project.

[Good Job](https://github.com/bensheldon/good_job) and [Que](https://github.com/que-rb/que) (postgres only) or [Delayed Job](https://github.com/collectiveidea/delayed_job) (any SQL database) are well-regarded Active Job adapters and all use your existing database (in better or worse ways depending or your specific application) and then you don’t need to run an additional piece of database infrastructure.