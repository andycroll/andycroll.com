---
title: "Try not to loop through associations inside jobs"
description: "Your local data isn’t the same as in production"
layout: article
category: ruby
image:
  base: '2022/try-not-to-loop-through-associations-inside-jobs'
  alt: "Roller coaster loops"
  credit: "Priscilla Du Preez"
  source: "https://unsplash.com/photos/FOsina4f7qM"

---

One of the downside of using an level of abstraction above your database is that it’s easy to accidentally give yourself performance headaches via running multiple very similar queries.

This is typically referred to as an n+1 problem, which is most often seen when you display an Active Record object in a view and show all of the associated records that `belong_to` to it. We often solve this by putting heavier database work in asynchronous jobs.

However, it’s too easy to underestimate how different production data is from your local machine and end up with long running loops _inside_ those jobs.


## Instead of…

…looping through lots of Active Record objects and updating them, even in a job:

```ruby
class UpdateManyCommentsJob < ApplicationJob
  def perform(post)
    post.comments.each do |comment|
      comment.update(name: comment.name.downcase)
    end
  end
end
```


## Use…

…enqueue each update in it's own job:

```ruby
class UpdateManyCommentsJob < ApplicationJob
  def perform(post)
    post.comments.each do |comment|
      UpdateSingleCommentJob.perform_later(comment)
    end
  end
end

class UpdateSingleCommentJob < ApplicationJob
  def perform(comment)
    comment.update(name: comment.name.downcase)
  end
end
```


## Why?

This is about parallelizing your work as much as possible and keeping each element of the work small. In this solution

Mike Perham, the author of [sidekiq](https://sidekiq.org)—who knows a thing or two about jobs—[suggests](https://github.com/mperham/sidekiq/wiki/Best-Practices#3-embrace-concurrency) that you “design your jobs so you can run lots of them in parallel”. In the proposed solution you end up with a single parent job enqueuing lots of sub-jobs rather than one long-running job making lots of database calls. This results in multiple benefits.

Providing you are running multiple workers on your background queue the total time taken to do the updates will be greatly reduced as the individual updates can be done in parallel, rather than serially in the loop.

In the case where a post has _a lot_ of comments, you also avoid a single long-running job that is hard to retry and may cause memory issues.

Consider loops within jobs a potential source of bugs in production and be wary.


## Why not?

In this contrived example, it would probably be fine. And in most cases running a small loop of updates on a `has_many` association in a job is also fine. Until it isn’t, in production.

Depending on the job you might be able to use other Rails features. You could use `update_all` to do all the updates for an association in one SQL query, but the update will likely have to be simple and no callbacks will run on the associated records.
