---
title: Don’t Loop & Do Work in Jobs
description: 'Loop and enqueue, then work on one object.'
layout: article
category: ruby
image:
  base: '2018/dont-loop-and-do-work-in-jobs'
  alt: 'Fruit Loops'
  source: 'https://unsplash.com/photos/chp1ITgplkA'
  credit: 'Etienne Girardet'
---

Getting as much of the slow or non-essential work of your application into asynchronous jobs is a good idea for the overall performance of your application.

## Instead of…

...doing jobs that iterate over a group of objects, doing work on each one.

```ruby
class DoABunchOfTranslationsJob < ApplicationJob
  def perform
    Text.find_each do |text|
      text.do_a_slow_translation
    end
  end
end
```


## Use…

...a job to enqueue a series of jobs that acts on every object individually.

```ruby
class DoABunchOfTranslationsJob < ApplicationJob
  Text.find_each do |text|
    DoASingleTranslationJob.perform_later(text)
  end
end

class DoASingleTranslationJob < ApplicationJob
  def perform(text)
    text.do_a_slow_translation
  end
end
```


## But why?

Jobs should ideally run as quickly as possible and make use of the concurrency of your asynchronous workers.

A single job doing 'lots' will run for a long time and thus is much more likely to encounter issues. These issues can be within the job itself, an error inside the loop or excessive memory use, or outside the job, if the the server needs to reboot.

If a long running job encounters an error, you have two problems, the ‘task’ is left in an inconsistent state and the long-running job will have to be run again from the beginning.

By breaking the work down into tiny repeatable pieces you increase the resilience of both the individual jobs and the wider ‘task’ as a whole. You also can make use of concurrency rather than running all the activity in a single thread.


### Why not?

There's an extra level of indirection; you end up making `BulkWhatever` jobs to enqueue the `Whatever` tasks.

For short-running loops this pattern might be overkill.
