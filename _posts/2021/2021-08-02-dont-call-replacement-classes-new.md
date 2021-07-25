---
title: "Don't call a new verison of something new"
description: "A opinionated naming subtlety"
layout: article
category: ruby
image:
  base: '2020/calculate-a-mean-average-from-a-ruby-array'
  alt: ""
  credit: 
  source: "https://unsplash.com/photos/3xwrg7Vv6Ts"

---

Often in long-lived applications we might want to rewrite or refactor the approach that we have previously taken.


## Instead of...

...using 

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

to rename or namespace the existing code. And create the replacement version with the correct future naming.

```ruby
module Removing
  class DoThingJob << ActiveJob
    # existing implementation
  end
end
```

```ruby
class DoThingJob < Removing::DoThingJob
```

Then change all the places the non-namespaced version is called. Then deploy and ensure that no jobs are still enqueued with the non-namespaced version.

Now you're free to reimplement in the correct (and future) location.

```ruby
class DoThingJob
  # new implmentation
end
```

Once you've built, tested and changed all the calls to the new version you can delete the (now unused) namespaced version.


## Why?

This is a habit that helps communicate intention.

These refactoring projects are often large in scale and easy to make mistakes. But this methodology clearly lays out the intention to replace this existing code.

If you call your new implmentation `NewSomething` it's not easy for other folks in your team (and future you) to understand the direction of development of the code. "Should I use the New version?"

You also won't be left with lots of `NewWhatever` objects littering your code when you inevitably don't do the final renaming.

Picking a single namespace for this kind of refactoring also gives you one place to look for all incomplete refactorings and unused code in your application.


## Why not?

There's no "code based" reason to do this, as this is a personal preference, plus it adds a little addtional ceremony in exchange for reducing errors.

You also shouldn't blindly copy existing naming. Perhaps there's a better word choice that more accurately reflects what the new code is doing?

If you're building an API consumed by customers/user outside your team this might not be a good solution. If you're developing a new version, you'll still likely to need to support the existing version. In this case a new `v2` namespace is a good idea.


## Anything Else?

You may want to couple this approach with [adding deprecation methods](https://andycroll.com/ruby/use-a-deprecation-message/) to your previous implementation to communicate more fully, through your code, with other members of your team.