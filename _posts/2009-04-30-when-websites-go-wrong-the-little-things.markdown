---
title: "When Websites Go Wrong: The Little Things"
layout: post
---

I gave a talk at the April 2009 [WebSG Meetup Singapore](http://websg.org) last night. A really great meetup, met lots of interesting people and heard a fascinating talk from Jon Petersen, a self styled [location geek](http://singeo.com.sg) who's new restaurant phone application [buUuk](http://buuuk.com) seems to be a fascinating project.

Quote of the night, for me, from Jon when talking about the big players in the handset world, "Nokia are the incumbent, but are doing everything in their power to lose the game".

There was also an interesting discussion about what the Government is doing right and wrong with their websites, where I hope Jussi and I didn't come across as 'European know-alls' particularly as our countries are nowhere near as plugged in as Singapore is. My key takeaway was that things are improving but there is still a tendency to treat websites as brochures/projects that can be completed. This is all well and good for the guys at the [HPB](http://hpb.gov.sg) who are regularly working on specific health initiatives, but there seems to be a mushrooming of individual disparate sites across the online state, rather than incentives to improve the core of what the Gahmen needs to do.

As for me I subjected the room to a slightly overrunning half hour of ranting about the horrendous state of some of the local websites, all caused by basic design problems. I'll cover some of what I said over a couple of blog posts.

## Caveat

All the criticism is valid for sites all over the world, but I focussed on sites specific to Singapore. I also focussed on the organisations with _actual_ budgets, no use giving a random guy a kicking about his blog! These are sites that really should do better, culled mainly from the [Hitwise Performance Awards 2008](http://sg.hitwise.com/other/awards-2009.php) (which in an ironic move is only available as a PDF file).

## The Little Things

### no-www

We're rapidly getting to the stage where we're not writing 'www' at the front of our URLs in fact [the iPhone omits them totally](http://daringfireball.net/2008/11/treating_url_protocol_schemes_as_cruft), how long before the desktop browsers follow suit?

With this in mind, you should be able to type http://whatever.com.sg into a browser and get the site. The fact that this *doesn't* work on some quite high profile sites is a travesty.

[Golden Village Cinemas](http://gv.com.sg), [Cathay](http://cathay.com.sg), [Gov.sg](http://gov.sg) - the tip of the iceberg. This is basic server competence, it's embarrassing.

You should also redirect to one canonical URL to avoid 'splitting you Google juice' (technical term). My preference is for the tidier [no-www](http://no-www.org), which can be done at the web server level or by including a short snippet in your `.htaccess` file.

### Date & Time

I didn't cover this on the day, but we must stop putting the current date and time on pages. I already have a clock on my computer, your website doesn't need to tell me.

### Colour

Think about it. The [Cathay ticketing website](http://tickets.cathay.com.sg) has a red text highlight on a bright green background a classic colour-blindness combination and the colours clash horrendously. _This actually changed by the time I came to write this up, less than 24 hours later, WebSG works!_

![Cathay ticketing red/green](/images/2009/cathay-ticketing.png)

### Don't Break the Browser

I didn't cover this either, although there's a whol other presentation on the dreadfulness of online banking. When I use my UOB online banking, the return key is disabled, by JavaScript, for form entry. Annoying for me, very bad for disabled users and I can't see any decent reason why I must _click_ the button.

There's other instances across many websites, where form try and 'help' the user by capitalising words or inserting characters in dates or even demanding numbers in specific formats. This should all be transparent to the user, the server side processing should deal with all of that stuff.

If you enter phone numbers with spaces, dashes, brackets or even the '+65' international formatting the application should just deal with it. You certainly shouldn't get terse error messages. It just leads to extremely poor user experience.

Also, don't launch new windows when I click on a link; it's rude, it breaks the back button and it's annoying. Thanks.

...more to come.
