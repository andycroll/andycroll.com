---
title: "Don't call a new version of something 'new' when refactoring"
description: "A opinionated naming subtlety"
layout: article
category: ruby
image:
  base: '2021/dont-call-replacement-classes-new'
  alt: "New"
  credit: Nick Fewings
  source: "https://unsplash.com/photos/1SsUquHPNT8"

---

In long-lived applications, we often want to rewrite or refactor an approach that we have previously taken to solving a problem.

Here's a, non-obvious, naming technique I've used during refactoring to ensure that the improved code ends up in well-named classes and that any old implementation are clearly marked for deletion.

You might find this helps to organise your work or better communicate the intent of future changes with your teammates.


## Instead of...

...littering your codebase with the word "new":

```ruby
class NewDoThingJob << ActiveJob
  # new implementation
end
```

or

```ruby
class DoThingJobVersionTwo << ActiveJob
  # new implementation
end
```


## Choose...

to rename or, better, namespace the existing code to mark it as deprecated. Then create the replacement version with the correct future naming.

```ruby
module ToBeRemoved
  class DoThingJob << ActiveJob
    # existing implementation
  end
end
```

```ruby
class DoThingJob < ToBeRemoved::DoThingJob
```

Where the non-namespace implementation is called, change it to call the implementation in the deprecated namespace. Then deploy and ensure that the application is working as expected and that the non-namespaced version of the code is not called or enqueued anywhere.

Now you can implement the new, improved approach in the correctly named location.

```ruby
class DoThingJob
  # new implmentation
end
```

Once you've built, tested and changed all the calls to the new version you can delete the (now unused) namespaced version.


## Why?

This is a habit that helps communicate intent.

These refactoring projects are often large in scale and it can be hard to see what's going on in the midst of a series of changes. This methodology clearly lays out the intention to replace existing code.

If you call your new implementation `NewSomething` it's not easy for other folks in your team (and future you) to understand the direction of development of the code. "Should I use the new version yet?"

Furthermore, you don't run the risk of being left with lots of `NewSomething` objects littering your code when you inevitably don't do the final renaming. :-)

Picking a single namespace for this kind of refactoring also gives you one place to look for all incomplete refactorings and unused code in your application.

This staggered renaming also lets you deploy changes in a series of smaller releases and avoids the creation of long-running refactoring branches that can be a nightmare to rebase, merge, and deploy.


## Why not?

This is a personal preference. There's no "code based" reason to do it.

Equally you shouldn't automatically copy existing naming. Take the opportunity when naming the _replacement_ implementation to better reflect what the new code is doing.

If you're building an API consumed by customers/users outside your team this might not be a good solution. If you're developing a new version, you'll still likely to need to support the existing version. In this case a new `v2` namespace is a good idea.


## Anything Else?

You may want to couple this approach with [adding deprecation methods](https://andycroll.com/ruby/use-a-deprecation-message/) to your previous implementation to communicate more fully, through your code, with other members of your team.
