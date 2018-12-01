---
title: "A job should know whether to run itself"
description: 'A little self.knowledge goes a long way.'
layout: article
category: ruby
image:
  base: '2018/a-job-should-know-whether-to-run-itself'
  alt: 'A queue'
  source: 'https://unsplash.com/photos/Nzb4LBsctyQ'
  credit: 'Hal Gatewood'
---

It is a good idea to do as much of the ‘work’ of an application as possible in asynchronous jobs as it means doing less work in each controller action. Rails includes `ActiveJob` as a way to implement this pattern in your application.

Each `ActiveJob` comes with a selection of callbacks that are run at different points in a job’s lifecycle.

A list of the available callbacks are in the [Active Job Rails Guide](http://guides.rubyonrails.org/active_job_basics.html#callbacks).

When a job doesn't always need to be run, we can use these callbacks to save writing conditional logic in every location in the code where we enqueue the job.


## Instead of…

…checking whether a job should be enqueued when you enqueue it…

```ruby
class SendNotificationJob < ApplicationJob
  def perform(user, message)
    # do work
  end
end

if user.wants_notifications?
  SendNotificationJob.perform_later(user, message)
end
```


## Use…

…use an early `return` to do nothing at the point the job is executed.

```ruby
class SendNotificationJob < ApplicationJob
  def perform(user, message)
    return unless user.wants_notifications?
    # do work
  end
end

# then
SendNotificationJob.perform_later(user, message)
```


# Or…

…throw the symbol `:abort` in a callback so a job does not enqueue itself.

```ruby
class SendNotificationJob < ApplicationJob
  before_enqueue do |job|
    user = job.arguments.first
    throw(:abort) unless user.wants_notifications?
  end

  def perform(user, message)
    # do work
  end
end

# then
SendNotificationJob.perform_later(user, message)
```


## But why?

The code enqueuing the job doesn’t need to care whether the work of the job needs to be done or not. It aids comprehension to keep the logic about when to do something near to the code that actually does the thing. This will make the code easier to understand when you come back to it later.

A job happens an unspecified period of time after it is enqueued. It's possible the answer to 'should this job be run?' could change between the enqueuing and the execution. This is a good candidate for the first, 'early return', style.

You should use the second, 'use throw in a callback', style when the condition for running a job is very unlikely to change between enqueuing and execution. This is because, with this style, the job is never enqueued if the initial condition isn't met. This is the exact same logic as the original example.

In both cases the code for the enqueuing is clearer without the external conditional at the point of enqueuing.

Both styles are valid approaches and you can even use them together for different conditions.


##  Why not?

The code for the ‘use throw in a callback’ style is slightly more complex than an external conditional when you enqueue.

Also it's only worth encapsulating the 'should the job be run' logic if the condition is always applied to the job.

There may be a slight performance cost of enqueuing (and then dequeuing) jobs when using the 'early return' style. You might be filling your queue with lots of jobs that don’t do anything.
