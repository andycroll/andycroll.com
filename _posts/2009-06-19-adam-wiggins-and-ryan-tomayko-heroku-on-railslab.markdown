---
title: "Adam Wiggins and Ryan Tomayko, Heroku on RailsLab"
layout: post
---

I should say from the off I'm a huge fan of [Heroku](http://www.heroku.com) as a platform, I just think it's incredible. The [Damascus Moment](http://en.wikipedia.org/wiki/Road_to_Damascus#On_the_road_to_Damascus) came when I converted [my football team site](http://tgafootball.com), typed `git push heroku` and my site was live, and virtually endlessly scalable (not that it needs to be). In the words of Bill and Ted, [Woah](http://www.youtube.com/watch?v=OT4B-NJUcZE)!

The abstraction of the deployment layer, Linux, Apache, Passenger, Ruby, is a huge win for me as it's the area of building my own stuff that is the least interesting and very much the most difficult. For the foreseeable I cannot see myself using anything else for Rails deployment.

RPM have been putting out some [regular screencasts on Rail performance](http://railslab.newrelic.com), and whilst I've been doing minimal Rails work for the last few months I thought I'd sit down and watch [Adam](http://adam.blog.heroku.com/) & [Ryan](http://tomayko.com/) from Heroku [interviewed by Mike Malloy](http://railslab.newrelic.com/2009/06/18/adam-wiggins-and-ryan-tomayko-heroku.

## Introduction

The introduction video talks mainly about the plan for Heroku and their vision for a next-generation hosting platform. Heroku were one of the first companies to embrace 'cloud computing', building that way from day one, but abstracting that from the user/developer experience.

Both the guys are heavily involved in open source stuff and were 'all over RailsConf 2009'.

They're looking to enable teams to quickly deploy apps with the speed that Rails, and similar techniques, have allowed development to speed up in recent years.

## Performance

Building the architecture, _the right way_ was the most important thing and for them caching at the http level was the right way. Caching is key for Heroku, creates a scalable platform.

Serving static assets, the standard way is to use Apache to look in the public folder and go around ruby to serve that file as quickly as possible. This however assumes your web server is on the same machine.

The app and the files are two resources that you probably want to scale independently, but that you've created an artificial limit on. If you put an http cache on the front of the app you can serve this stuff much faster, and thus better.

### Any common issues with customer's apps on Heroku?

Doing too much in the single request context; you either want to re-engineer for speed or put it into a asynchronous job. Requests coming into the back too much, solved partially by the http caching. These have been common themes in the Rails world over the past couple of years.

Heroku is trying to provide the infrastructure around the Rails app, make it simple to plug this stuff in and experiment without having to have the overhead of installing and running these services.

As a developer you know these techniques are the right thing to do, but they might need another server which is extra headache; so you end up doing things the wrong way. Heroku is an attempt to make 'doing things the right way' the easy option. If you build an app the right way in the beginning it can hopefully scale better over time, avoiding rewrites.

### Background Jobs

This is beginning to be a bigger movement in the Rails community. You don't want your requests to be too long (more than 500ms?) you should throw those longer running tasks on a queue.

The nearest thing to a standard way of doing this is [Delayed Job](http://github.com/tobi/delayed_job), uses the db as the queue, which is very convenient. Throw the plugin into your app and you can start making these delayed requests.

This approach is good for scaling, performance and user experience. It changes the way you architect your app, breaking it into heavy lifting and requests. The web portion of your app can then concentrate on responding with information and not just spending a lot of time spinning. Having that structure and seperating out where you put your code can make an app feel much 'cleaner'.

### What is a Good Tip to Improve Scalability?

Think about where you put your data, Rails' design encourages the database to be the home for all data, potentially even including assets. Tendency to use database as a convenient bucket to throw everything.

Unfortunately the SQL-based database doesn't scale horizontally very well. Key-Value database are coming over the horizon to save us, but not soon. Serve assets from a distributed store such as Amazon S3. If it's transient data (metrics for example) see if you can use a service to store it.

_Keep your SQL database for your long term business data._

No silver bullet, have an idea of the options you have, and invest time getting familiar with profiling tools. Not always that Ruby is slow, it may not even by the Ruby tier of your app. Easy to have simplistic view, but it is key to find out what your scalability issues are.

### Tools Used at Heroku

Performance-wise, use NetCat or AB to genreate network load. A lot of their internal apps are not Rails based, more 'machineware'. Smaller Sinatra or Rack apps, they use Rack Profiler that gives a breakdown of I/O, user and system on a per request basis. Unglamorous tools, but for doing performance work it's crunching lots of data or simulating many users.

Use New Relic: has been instrumental in bringing on large client with load issues into the Heroku cloud. Glued to the stats, to find the areas where the site had problems.

Less local tools more outsourced serviced processes, for example Exception processing tools, [Hoptoad](http://hoptoad.com,) [Exceptional](http://getexceptional.com.) You get an API key, plug it in and then your app sends data to these services and you can use them outside of your app. [Lighthouse](http://lighthouseapp.com/) or even [Google Apps](http://google.com/a/,) it used to be you needed all these things setup internally, but now you don't.

Continuous integration, pain to set up so people leave it until they _really_ have to, [run>code>run](http://runcoderun.com/) is a promising service. Ticket tracking, performance monitoring all run by someone else giving it a nice user interface and you linking in through APIs is something that we're gonna see more and more of.

They use IRC for chat, use git for source control, but not much more for team management. They're a team of laptop nomads, no desks, everyone just sits with each other. The fact they're using EC2 means they don't need to be near the physical servers. A fine thing.

All their development is against EC2 as well, which surprises some people. Each developer has a cluster of EC2 instances, and they develop in the cloud. All virtual hardware, means their development environment is the same as their production. It makes it harder to use textmate, but most of the team are vim users. (Except their frustrated designer!)

