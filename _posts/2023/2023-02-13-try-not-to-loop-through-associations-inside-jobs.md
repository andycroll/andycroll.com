---
title: "Try not to loop through associations inside jobs"
description: "Your local data isn’t the same as in production"
layout: article
category: ruby
image:
  base: '2023/try-not-to-loop-through-associations-inside-jobs'
  alt: "Roller coaster loops"
  credit: "Priscilla Du Preez"
  source: "https://unsplash.com/photos/FOsina4f7qM"

---

One of the downsides of using Ruby to interact with your database, rather than SQL directly, is that it’s easy to accidentally give yourself performance headaches via running multiple very similar queries. Although the advantages of using Active Record (or something similar) are generally worth it!

This is typically referred to as an N+1 problem. They occur most often seen when you display an Active Record object in a view and show all of the associated records that `belong_to` to it. When lots of records _do_ need to be loaded or saved to the database you can putting this heavier database work in asynchronous jobs.

However, it’s too easy to underestimate how different production data is from your local machine and therefore it‘s easy to end up with long running loops _inside_ those jobs.


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

…a separate job for each update:

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

This is about parallelizing your work as much as possible and keeping each element of the work small.

Mike Perham, the author of [sidekiq](https://sidekiq.org)—who therefore knows a thing or two about jobs—[suggests](https://github.com/mperham/sidekiq/wiki/Best-Practices#3-embrace-concurrency) that you “design your jobs so you can run lots of them in parallel”. In the proposed solution you end up with a single parent job enqueuing lots of sub-jobs rather than one long-running job making lots of database calls. This results in multiple benefits.

Providing you are running multiple workers on your background queue the total time taken to do the updates will be greatly reduced as the individual updates can be done in parallel, rather than serially in the loop.

In the case where a post has _a lot_ of comments, you also avoid a single long-running job that is hard to retry and may cause memory issues.

Consider loops within jobs a potential source of bugs in production and be wary.


## Why not?

In most cases running a small loop of updates on a `has_many` association in a job is also fine. Until it isn’t, in production. And this is the point.

Depending on the job you might be able to use other Rails features. You could use `update_all` to do all the updates for an association in one SQL query, but the update will likely have to be simple and no callbacks will run on the associated records.

I was reminded by [Dave](https://ruby.social/@slimdave/109857575361894630) that it might be tricky to use this technique if you’re using counter caches. Or if your updates need to be transactional.

This technique is also likely to lead to a higher workload for the database as your jobs run lots of similar updates in parallel against the same table.