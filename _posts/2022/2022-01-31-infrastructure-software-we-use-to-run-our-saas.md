---
title: "Software & Infrastructure we use to Run Our SaaS"
description: "If you do a lot with a small team, you have to pay for softare"
layout: article
category: ruby
image:
  base: "2022/infrastructure-software-we-use-to-run-our-saas"
  alt: "Frame of a building under construction"
  credit: "Jacek Dylag"
  source: "https://unsplash.com/photos/nhCPOp4A2Xo"

---

Our team at [CoverageBook](https://coveragebook.com/) (and [AnswerThePublic](https://answerthepublic.com/)) do _a lot_ with a _very_ small number of developers and designers. Over 4,000 paying customers and 600k monthly visitors (many using a free version of our product) all with a product team of five, including me.

One of the key principles we use to keep our lives calm, and reduce the stress of supporting so much with so few folks, is to buy a lot of software to support our products and reduce the burden on us.

This results in the augmentation of our team with _lots_ of paid software products and services.

We resist building ourselves and pick the simplest, most pleasing-to-use software for the job. We even try, wherever possible not to configure away from the default settings!

Unless I specifically mention it, you can take our usage of these products as an implicit recommendation. Not that there aren’t other alternatives, perhaps better for you, but this is what we’re mostly happy with.


## Why?

Even the most expensive infrastructure bills pale in comparison to the cost of hiring a human being to build and maintain that code.


## Why not?

I mean, if you’re Amazon or Google or Facebook or Apple or Twitter you might want to build to your unique scale and requirements. But then you’ll be hiring thousands of developers and you’re in a _very different_ world to me.

This approach scales surprisingly well to teams an order of magnitude (or two) bigger than our team.

You do often have to make choices that may not be to your ideal aesthetic of functional choice, but even in this “paid for” software world there are plenty of alternative approaches from which you can assess and pick your favourite.

## Our list

### Application Framework: [Rails](https://rubyonrails.org)

Its popularity waxed (at least in the “public square”) for a couple of years, but it feels like a renaissance of sorts is happening as the JavaScript everywhere bubble is bursting.

_Lots_ of bigger, hairier software products use it and there is no better solution for small teams doing big, mostly web, applications while remaining happy and productive.


### Background Processing: [Sidekiq Pro](https://sidekiq.org)

We make heavy use of the paid version of this background procesing system for Ruby.

The important Pro features for us are the enhanced reliability, the web UI search and, in places, the batching functionality.


### Hosting & CI: [Heroku](https://heroku.com)

Fundementally this means that we do not have the ability to break our own infrastructure. If I was to make one recommendation to anyone starting a software service it would be use a service like this where you have to configure nothing.

The inflexibility of infrastructure choice means deployment remains simple and you have to work hard to insert idiosynratic complexity you don't need.

You’re not totally isolated from infrastrucre concerns and you might have to architect your application in a certain way to make the most of how a Platform-as-a-Service (PaaS) Heroku works, but you are spared the overhead of managing fleets of servers or containers.

They also run our PostgreSQL and Redis databases and rely on their CI & Pipelines to manage deployment.

#### Scaling: [Hirefire](https://www.hirefire.io)

Automatically scales our heroku dynos based on response time and queue backlog. Solid.

#### Testing Parallelisation: [Knapsack Pro](https://knapsackpro.com)

Added to our Heroku CI to parallelise it. The integration was very easy and it cut our builds to under 5 minutes. Most of that time is during setup: installing a browser for our system tests.

### Performance, Errors & Uptime: [AppSignal](https://appsignal.com)

Not as deep technically as some APM software, but at the right level for us and covers a bunch of infrastucture monitoring bases. Works nicely with Heroku. For instance the AppSignal PostgreSQL dashboard gives better insight than the (frankly poor) Heroku version.

And they send out [stroopwafels](https://www.appsignal.com/waffles).


### Application Security: [Sqreen](https://sqreen.io)

One piece of software that I'm especially glad to have found. It constant reviews and protects our applications from both deliberate attacks from troublemakers and our own inadvertanty security issues.

Purchased by Datadog, I guess they’ll wind that into their main product at some point.


### Logging: [LogDNA](https://www.logdna.com)

A nice UI and reasonable pricing for our volume.


### Static Site Hosting: [Netlify](https://netlify.com)

Our static sites are deployed here, we also make some use of a couple of very simple JavaScript “serverless” functions that are called from our applications.

It has a similarly straightforward deployment approach to Heroku, which is one of the main reasons we use it.


### CDN: [Fastly](https://fastly.com)

Solid CDN. The main players are all much of a muchness in this arena. We're only (currently) using it for our Rails assets.


### Payment Processing: [Stripe](https://stripe.com)

Why would we use anything else to deal with our credit card transactions? Arguably without it, the business would have struggled to get off the ground.

I speak as a man who previously implemented online credit card processing directly with banks. It was horrible.


### Code Collaboration: [Github](https://github.com)

Where our code is stored, reviewed and merged. Pretty standard for a modern development team.

We have a couple of Github Actions that we use for linting our code and compressing our images before merging.

We also use the [dependabot](https://github.com/dependabot) functionality Github absorbed.


### Image CDN: [Imgix](https://imgix.com)

There’s a bunch of products that perform this task but their API is the most pleasant of any we’ve seen and their pricing is fair. Good and engaged support.


### Video CDN: [Mux](https://mux.com)

Our video CDN of choice. Lovely product, good on site player and very nice API.


### Video: [Wistia](https://wistia.com)

We serve some of our video marketing assets through here, we also use YouTube.


### Cloud Storage: [AWS S3](https://aws.amazon.com)

We use Amazon’s storage because it’s the industry default, we should probably look at alternatives. AWS’s dashboard terrifies me every time I open it.


### Screenshots: [Urlbox](https//urlbox.io)

Really decent solution for taking screenshots. Not perfect (we have to do a bunch of special configuration on our end) but a nice API to getting screenshots of websites.


### Alerting: [PagerDuty](https://pagerduty.com)

It's _way_ more than we need and the scheduling is complex and byzantine. But reliable and _fine_.


### Status: [Statuspage](https://www.atlassian.com/software/statuspage)

I don't much like it, but it does what we need.


### Email: [Postmark](https://postmarkapp.com)

Great software from good people, really terrific deliverability for critical, transactional email. Visibly faster than all the other transactional mail services. Also terrific support.

We haven't expanded to use their broadcast email product.


### Geolocation: [IPStack](https://ipstack.com)

Simple, cheap, geolocation by IP address.


### File uploading: [FileStack](https://filestack.com)

Nice JS-powered uploader, a requirement to avoid using heroku dynos for file upload. We use other (better) solutions for serving the images, files & videos.


### A bunch of “not infrastructure” tools

[Basecamp](https://basecamp.com) for team communication and not much else (we may move after a decent testing period with [Twist](https://twist.com)), [Trello](https://trello.com) for medium term product planning.

[Fireside](https://fireside.fm) to host the podcast, but I'd probably go with [Transistor](https://transistor.fm/?via=andycroll) these days.

We host our blog on Wordpress hosted by [Flywheel](https://getflywheel.com) primarily due to it's excellent development experience.

[ConvertKit](https://convertkit.com) has somewhat moved away from being an ideal tool for SaaS email marketing communication, but it’ll do for now.

[Intercom](https://intercom.io) used to be the best tool for support. Now it’s bloated, confused, with ironically poor support (!) and seems mostly interested in squeezing every customer for the most money while changing “account managers” every six months. If we could be bothered to move, we would.
