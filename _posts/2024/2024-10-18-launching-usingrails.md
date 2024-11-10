---
title: "Launching UsingRails: A Directory of Rails-Based Organisations"
description: "Why build and launch directory to celebrate Ruby on Rails"
layout: article
category: ruby
date: 2024-10-16 01:00
image:
  base: "2024/launching-usingrails"
  alt: "UsingRails logo"
---

In the week or two before Rails World (two words), I launched [UsingRails](https://usingrails.com). It’s a directory of Rails-based organisations and companies.

It's the culmination of a couple of years of research, a rapidly built Rails application and the world’s largest Apple Note.

## Why?

I've been a Rails developer for a long time. I've built a few Rails applications, and I've been involved in the community for a while. The external narrative of Rails is that it _was_ a great platform for building web applications, but somehow it’s no longer a good choice. This is despite the continuing push of the framework to improve and evolve as the best way to (joyfully) build useful web and native applications with small teams.

UsingRails is one way to address that nonsense/lie/misconception.

I’d been collecting a list of Rails-based organisations (primarily their domains) for a while in the world’s most disorganised Apple Note, through reading various newsletters, job boards and Ruby mailing lists. I’d also been nudged by [Irina](https://x.com/inazarova), when we were talking earlier in the year about her RailsConf keynote.

## The technical side

Obviously, the site is built with Rails. It was a chance to play (pre-release) with the new Rails 8 hotness. I’d started on edge, but had to drop back to 7.2 for the latter stages of the build due to some small incompatabilities and minor bugs. A Rails 8 upgrade is in the offing in the near future.

The app uses SQLite, incorporating the suggestions & improvements Stephen Margheim recommended in his [RailsConf workshop](https://github.com/fractaledmind/railsconf-2024/) and subsequent [talks](https://fractaledmind.github.io/2024/10/16/sqlite-supercharges-rails/) & writings.

Backups are via the [`litestream-ruby` gem](https://github.com/fractaledmind/litestream-ruby) and I used Stripe-style primary keys using the ulid SQLite extension via the `sqlpkg` gem. All remarkably straightforward thanks to the huge advances in Rails 8’s SQLite support.

I’ve hosted it (for now) on Digital Ocean (including using their S3-compatible file storage for Active Storage and SQLite backups) and deployed using Chris Oliver’s [Hatchbox](https://hatchbox.io).

This was a chance to explore outside of the cloud providers and to see the current state of deployment to VPS-like solutions. Short story: it was pretty great, a (re)learning experience and a shot across the bow of Heroku in my main usage context at work.

I was also an early adopter of [Solid Queue](https://github.com/rails/solid_queue), even finding a new way to break the complex interdependencies both in production and in development.

So I did some ”contributing” to open source as a result of this living on the edge. Sort of. I posted a resonably detailed shrug of a ["I broke this, any ideas?" GitHub issue](https://github.com/rails/solid_queue/issues/324). Then the marvellous, smarter-than-me, folks of the community and showed up, discussed and then finally [solved it for everyone](https://github.com/sparklemotion/sqlite3-ruby/pull/558). Ten out of ten, would break stuff again. Thanks Mike, Rosa & Stephen.

Given the level of data-collection I'm doing and the protected administation interfaced, I wrote minimal tests, but when I did I wrote minitest, rather than RSpec which is our day-to-day framework at CoverageBook. I quite liked it.

I've also adopted a couple of gems—with exceptional Rails-level taste and author pedigree—that I hadn’t used in anger before, including [`active_job-performs`](https://github.com/kaspth/active_job-performs) from Kasper and [`frozen_record`](https://github.com/byroot/frozen_record) from Jean. Would recommend both.

I used the generators from [`authentication-zero`](https://github.com/lazaronixon/authentication-zero) to enable GitHub Authentication (only) sign on for the site. Primarily I'm using that authentication to avoid spamming of the directory with fake accounts and organisations, given I'm manually reviewing all of them.

## The Launch

I launched with 1,500 organsations and in the month since the community has volunteered 500 more with new ones being added every day.

I was pretty happy with the launch posts on social, plus the general vibe of folks exploring the site and submitting their own organisations, or ones they are aware of.

[AppSignal](https://appsignal.com) is my preferred solution to monitor the site performance as I can just plug and play and I'm familiar with it form work. As I'm monitoring I can tell you that the particular combination of technologies in the Rails 8 stack (SQLite, Solid $Whatever) make the app _very_ fast and responsive.

The site recently got <a href="https://www.reddit.com/r/rails/comments/1g3dbz5/can_we_show_some_love_usingrailscom/">posted to Reddit</a>, causing a new rash of submissions, so I could obviously do a better of letting people know this thing exists. Maybe it’s a good idea to go and see if your company or organisation is listed?

## The Future

The site is still in its infancy, but I’m looking forward to having a side project that has such an obvious benefit for the community as well as a place to play. Job-hunting, social proof and just a sense of the sheer number of the "missing middle-sized" companies in the Rails ecosystem.

Been asked a couple of times about code contribution, but I'm not ready to manage other folks’ time and I'm enjoying hacking away on my own private, fun, codebase. Maybe in the future? But I am happy to hear where things could be clearer or better or more useful.

I’m only scratching the surface of the breadth and depth of our community and am beginning to explore collecting more data. Am loving the initial feedback and insights from visitors for further improvements, so let [me know](mailto:andy@usingrails.com) if you have any suggestions.
