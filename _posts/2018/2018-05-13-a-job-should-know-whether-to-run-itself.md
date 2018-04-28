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

It is a good idea to do as much of the ‘work’ of an application in asynchronous jobs as it means doing less work in each controller action. Rails includes `ActiveJob` as a way to implement this pattern in your application.

Each `ActiveJob` comes with a selection of callbacks that are run at different points in its lifecycle.

A list of the available callbacks are in the [ActiveJob Rails Guide](http://guides.rubyonrails.org/active_job_basics.html#callbacks).

When a job doesn't always need to be run, we can use these callbacks to save writing conditional logic every time we enqueue one.


## Instead of…

...checking whether a job should be enqueued when you enqueue it...

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

...use an early `return` to do nothing at the point the job is executed.

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


# Or...

...throw the symbol `:abort` in a callback so a job does not enqueue itself.

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

It generally aids comprehension to keep the logic about _when_ to do something near to the code that actually does the thing.

Use the 'early return' style when the property might change before the job runs, For example, if you scheduled a job to run in the future and the property of the object the job affects might change.

Use the 'callback and throw' style when the enqueuing should be based on a condition that is unlikely to change.

In both cases the code the code for the enqueuing is clearer without the conditional. The enqueuing code doesn’t need to concern itself with whether the work the job needs to be done or not, the job itself can decide.


##  Why not?

There may be a slight performance cost of enqueuing (and then dequeuing) jobs when using the 'early return' style. You might be filling your queue with lots of jobs that don’t do anything.

There are also subtle logical & timing differences between the three approaches for 'not running a job'. It requires careful consideration of these factors to establish which choice to make.

This is one of those cases where all three are valid approaches and you might even use them together for different conditions.
