---
title: 'Rails Naming Cringes'
description: 'God model naming expansion, laziness & reserved words.'
layout: article
category: ruby
image:
  alt: 'print letters'
  base: '2016/rails-naming-cringes'
  credit: 'Amador Loureiro'
  source: 'https://unsplash.com/photos/BVyNlchWqzs'
---

Rails has a number of naming conventions that are as deeply ingrained as the `/app` directory or `belongs_to`. However even experienced developers (including me) forget the that one of the finest things Rails ever did was to give us a ‘way things should be named’ and a place for them to go.

Here are a couple of things that make my ‘naming spidey sense’ tingle when I see them in a codebase.

<blockquote class="blockquote">
  <p class="mb-0">Programs must be written for people to read, and only incidentally for machines to execute.</p>
  <footer class="blockquote-footer">Harold Abelson <cite title="Source Title">Structure and Interpretation of Computer Programs</cite></footer>
</blockquote>

## God model naming expansion

God models, the bane of many apps. Giant, unwieldy, immobile mountains of code clustered around the main concepts of your application attracting quasi-related code.

It’s not that these concepts are bad, more that the ‘gods’ in question grow to thousands of lines and wrap their tentacles deep into all the parts of your application, which makes it hard to refactor and change functionality.

`User` is a candidate in most Rails applications then typically whatever else the majority of your application is ‘about’. If it’s a training app, one of your god models might be `Course`. If it’s a small ads website it might be `Listing`.

Breaking up a ‘god’ is somewhat outside the scope of this article and is often incredibly difficult.

However a more curable ‘naming infection’ you often see is the proliferation of the name of the ‘god’ in the names of related models.

A `Listing::ListingList` could probably just be a `List` or `Shortlist` rather than constantly splashing the god’s name all over your codebase. A `UserCourse` might be better expressed as an `Enrollment`.

All this does is focus even more developer 'brain space' on the god models and cause confusion for those new to your codebase.


## Lazy naming

You’ll sometimes see the name of the model repeated as a field in very simple concepts. For example: a `comment` field inside a `Comment` model in a blogging application which contains the body of text.

It’s simply time to take a minute and better name the concept.

In this case `body` would be a better choice.


## Reserved word collisions

This is simply naming something the same as a reserved word in Ruby or Rails: `request`, `action`, `require`, `display`, `type`.

There are lots of examples, some will break, some will give you weird side effects. They tend to be quite generic, which is probably a sign you haven’t probably thought about your naming enough.


## Not changing “legacy” field names

On a vacation rentals project I worked on we had a bunch of boolean fields that acted as ‘tags’ on a room object. A couple of these fields were `non_smoking` & `non_smoking_2` which meant respectively: a non smoking room and _a smoking room_.

Every time I came up against this I had to remember what _exactly_ was going on. Every time someone new came to this part of the code they were confused and baffled.

This increased confusion and meant there was a need for this anti-information to become an institutional myth when there was absolutely no need.

Not only that, when we were breaking off the specific code into a larger service, the name was simply ported across verbatim without ‘cleaning up as we went’ so the confusion persisted in this new ‘clean’ system.

Which compounded the original error. _Not a glorious day_.


## So…

Visual noise and naming confusion are major roadblocks to building a mental model of the system you are writing.

This is why naming is so important. I recommend reading section 4.2 of [99 bottles of OOP] by Sandi Metz & Katrina Owen where they give multiple strategies to get to “good names” for things. There is a terrific example of Katrina’s passion for naming in her talk [Succession](http://www.confreaks.tv/videos/railsconf2016-succession) from RailsConf 2016.

Naming is _the most important thing_ for newcomers to your codebase and also future you — the you that's forgotten all of the context. It’s worth spending a little time to get it ‘right’ the first time and always re-examine when you touch the code again.

_Thanks to [Nadia](https://twitter.com/nodunayo) for feedback on drafts of this article._
