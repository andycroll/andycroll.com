---
title: "Reset Your CSS or Suffer the Consequences"
layout: post
---

At [work](http://www.bezurk.com), I was recently was tasked with a quick fix of an issue that has been plaguing the company as it gets press from [all right thinking people](http://money.cnn.com/galleries/2007/biz2/0707/gallery.web_world.biz2/8.html). People using the logo from the home-page, a graphic with a built-in yellow corner.

So I made some changes in our slightly random CSS (change is coming!) swapped out the background-image with a logo with a transparent corner and set a CSS background color to match the page background. I tested in IE6, IE7, Firefox and Safari and thinking all was well I deployed it.

However I'd managed to (inadvertently) uncover a curious issue. I received an email with this image attached saying the site was a bit broken in Windows Firefox.

You'll note the unfortunate white line above the logo. After some head scratching, I worked out a kludgy hack to sort the issue by absolutely positioning an image on the containing element to the top right - so it kinda works. Then set about finding an elegant solution.

I isolated the problem in thinking that the problem had uncovered a difference in rendering between Windows and Mac Firefox. I was however wrong. If you change the height of the browser window in  Firefox the white line appears and disappears but not in Safari.

After much head scratching, I looked at the computed margins in Firebug for the h1 element. Lo and behold 18.2px of top and bottom margin that despite the negative indenting of text was somehow effecting the positioning. Problem solved by zeroing the margins of the h1.

### Moral of the Story

In traditional [Aesop-ian](http://en.wikipedia.org/wiki/Aesop's_Fables) style, there is a moral to this tale. *Use a reset style-sheet*, our current home-page doesn't and this is why we were getting funky behaviour. Needless to say the next version of the home-page will be a standardista's wet dream.

Even the standards compliant browsers render differently from each other and have slightly a slightly different assumed base set of styles. A reset gives you a more consistent base to work from. Yahoo [have one](http://developer.yahoo.com/yui/reset/), but I'm a fan of the [Meyer reset](http://meyerweb.com/eric/thoughts/2007/05/01/reset-reloaded/) - it's succinct and [Andy Clarke](http://www.stuffandnonsense.co.uk) uses it, that's good enough for me.