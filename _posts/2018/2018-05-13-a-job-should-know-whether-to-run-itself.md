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

Like other `ActiveWhatever` objects in Rails, a job also comes with a selection of callbacks that are run at different points in it's lifecycle.

A list of the available callbacks are in the [Activejob Rails Guide](http://guides.rubyonrails.org/active_job_basics.html#callbacks).

We can use these callbacks to save a lot of conditional logic for jobs that might not always need to be run.


## Instead of…

...checking whether a job should be enqueued when you enqueue it...

```ruby
class DoItLaterJob < ApplicationJob
  def perform(thing)
    # do work
  end
end

if thing.should_be_done?
  DoItLaterJob.perform_later(thing)
end
```


## Use…

...use an early `return` to do nothing at the point the job is executed.

```ruby
class DoItLaterJob < ApplicationJob
  def perform(thing)
    return unless thing.should_be_done?
    # do work
  end
end

# then
DoItLaterJob.perform_later(thing)
```


# Or...

...even throw the symbol `:abort` in a callback so a job does not even enqueue itself.

```ruby
class DoItLaterJob < ApplicationJob
  before_enqueue do |job|
    thing = job.arguments.first
    throw(:abort) unless thing.should_be_done?
  end

  def perform(thing)
    # do work
  end
end

# then
DoItLaterJob.perform_later(thing)
```


## But why?

It's generally aids comprehension to keep the logic about _when_ to do something near to the code that actually does the thing.

Use the 'early return' style when the property might change before the job runs, For example, if you scheduled a job to run in the future and the property of the object the job affects might change.

Use the 'callback and throw' style when the enqueuing should be based on a condition that is unlikely to change.

In both cases the code where the enqueuing happens becomes clearer without the conditional. This is a case where either situation can be the correct path, it’s a matter of context.


##  Why not?

There may be a slight performance cost of enqueuing (and then dequeuing) jobs when using the 'early return' style. You might be filling your queue with lots of jobs that don’t do anything.

There are also subtle logical & timing differences between the three approaches for 'not running a job'. It requires careful consideration of these factors to establish which choice to make.

This is one of those cases where all three are valid approaches and you might even use them together for different conditions.
