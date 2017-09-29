---
title: "The end of :hover?"
description: 'As we move to fingers as a primary input device.'
layout: article
category: development
redirect_from:
  - /2010/06/08/the-end-of-hover/
  - /design/the-end-of-hover/
image: '2010/the-end-of-hover'
imagealt: 'Hummingbird'
imagecaption: 'Photo by [Bill Williams](https://unsplash.com/photos/ozwiCDVCeiw) on Unsplash'
---

When I sat down to a redesign of the Gameplan admin interface I suddenly came to a realisation, `:hover` doesn’t work. It's entirely possible I'd skim read this somewhere, but somehow the implications for my design work had passed me by until I saw an iPad in use.

As so eloquently pointed out in [this article](http://www.roughlydrafted.com/2010/02/20/an-adobe-flash-developer-on-why-the-ipad-cant-use-flash/) this lack of hover (along with the technical and performance issues) is one of the reasons making the iPad run flash is not something Apple are keen on.

Apple's own notes even suggest that [javascript onmouseover over and CSS hover events maybe unreliable](http://developer.apple.com/safari/library/technotes/tn2010/tn2262/index.html#//apple_ref/doc/uid/DTS40009577-CH1-DontLinkElementID_6). I did also discover an article that suggests the iPad does in some cases support the [javascript method](http://billhiggins.us/blog/2010/04/05/the-ipad-and-onmouseover/) , but as I don’t have an iPad (due to Singapore's 3rd tier release status) I can’t tell you.

So my proposition is this: `:hover` as an web interface design tool going forward is going to be less and less important.

As to whether this is a good or bad thing I'm not sure.

When used elegantly it removes visual noise and improves the feel and functionality of the page; only revealing more detailed information when contextually relevant. Twitter does this: reply, retweet, favourite and delete all appear when you hover over an individual tweet. 37signals products also do this to hide drag controls as well as edit and delete links.

However, `onmouseover` and `:hover` have often been used as an excuse to temporarily hide complexity in the navigation, often as a compromise. The designer and/or UI team preach simplicity in both structure and visuals but the man holding the money demands an incredible hierarchy of constantly expanding [suckerfish-style menus](http://www.alistapart.com/articles/dropdowns) addressing every page in the site. We've all done the navigation-menu-hover-and-exacting-slide only to have the sought for menu item disappear as the pointer gets near.

What we do know is Apple is well aware of this. If you look at their own sites you'll see that they've known this was coming for a long time. Look at the [trailers site](http://trailers.apple.com/trailers/universal/scottpilgrimvstheworld/). Each trailer page has a widget that requires a click (or tap) to open where a previous solution to hiding content might have been to hide until hover. You can also see their approach in the liberal use of lightboxes across their product pages.

A solution for subtly altering layout on a touch based device appears to be coming based on [this commit](http://github.com/Modernizr/Modernizr/commit/59ef6d8096bd715efabda3effb707bba69b1c054) to [Modernizer](http://www.modernizr.com/) a clever little js library that detects support for various browser functionality, and is [well recommended](http://www.stuffandnonsense.co.uk/blog/about/cannybill_design_process_package_contents/).

I know that I'll certainly be considering 'tap to toggle' as a user interface choice ahead of hover in the future. The iPhone-ification of interaction online continues.
