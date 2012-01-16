---
title: "Design Fast Websites, Nicole Sullivan"
layout: post
---

Nicole Sullivan is a Performance Engineer & International Evangelist at Yahoo, her work involves optimising and streamlining performance on large scale websites from a front-end perspective. Here's another useful note session from an content-packed video.

This talk on [not blaming the rounded corners](http://www.stubbornella.org/content/2008/12/28/design-fast-websites-rounded-corners-yui-theater/) is is on the [YUI Theater](http://video.yahoo.com/watch/4156174/11192533?v=4156174).

## Speed Matters

From large scale research it is clear that ever last bit of performance matters, even slowing pages by a fraction of a second makes a difference.

* Adding 100ms to the response time meant a 1% drop in sales on Amazon
* Adding 400ms resulted in a 4-9% loss in full pages loads - abandonment on Yahoo (Home & Autos)
* Adding 500ms, only half a second, resulted in 20% fewer searches Google

Make your users happy, users care if sites are fast. Performance is part of both back-end and front-end development, make it an important part of your process.

Here are Nicole's Nine Best practises (with some extra notes from your truly)

### #1 Create Component Libraries

Think about your website in terms of consistant building blocks; headings, lists, headers, footers, grids, buttons. Build these reusable elements and you have a performance freebie as the functionality, css and images are already downloaded.

Nicole advocates thinking about things in terms of chunks, page objects or [legos", bits of content design you can use over and over. When doing this try to avoid redundancy, or having multiple very similiar objects (a clsssic Rails-style Don't Repeat Yourself approach). A good rule of thumb is that if you wouldn't put two 'modules' side-by-side they shouldn't be on the same site.

_For a most large scale web applications I'd also consider standardising my forms as much as possible._

### #2 Using Consistent Semantic Styles

Don't drastically change the look of a heading or a list depending on where it is in the site. This is not only a performance issue but frankly good IA; "Think of the users!"

This is also important for future development, predictable components encourage reuse in future development.

_Not sure I agree necessarily. I think you can, but do it sparingly. i.e. a Home page might need larger typography than those in a sub section._

### #3 Design Modules to be Transparent on the Inside

Use your simple building blocks to create a variety of layouts. It can give you a lot of visual language using only a few blocks, aiming at a 1:n relationship.

Tough to do on gradients and background images, there may be a need to push back on the designer.

_She talks about an [ALA article on mountain top corners](http://www.alistapart.com/articles/mountaintop/) for implementing rounded corners using example html code, but I'm not sure I agree with that article approach. For me, these days, IE gets square corners._

### #4 Optimize sprites and images

Generally sprites have meant through everything in one page but the classic Good, Fast & Cheap triangle comes into play.You can have Many pages, Easy Maintenance & Super Otimization. But only two of three.

e.g Google's page structure has 2 pages: a search page, and a results page, so it can have easy maintenance and the super optimized sprite.

A good technique is to sprite together images that _go together_, [object oriented spriting". Buttons? Window chrome? Navigation? This helps maintainability in the future.

9 ways to optimize images:

* Combine like colors, if you can get below 256 colors, big savings
* Avoid whitespace in the sprite, particularly with mobile
* Horizontal better than vertical
* Limit Colours
* Optimize individually then sprite
* Reduce anti-aliased pixels, crispness is important
* Avoid Diagonal gradients
* Avoid alpha transparency, there is a big performance hit in IE6 forcing it to do PNG24 alpha transparancy
* Change gradient color every 2-3 pixels, this will trick the human eye dependant on gradient

Be careful with logos, they are super recognisable, so small changes will be noticed!

Try progressively enhanced PNG8, its a great way to avoid [alphaimageloader](http://www.alistapart.com/articles/pngopacity/) which in IE6 leads to increased memory consumption, for every affected element. If you must use it only target IE6.

_I'm a big fan of IE6 conditional comments and using [SuperSleight](http://24ways.org/2007/supersleight-transparent-png-in-ie6) from Drew McLellan._

Add in a couple of partially transparent pixels to a binary transparent file can make all the visual difference, you need to use Fireworks as it has the support.

Good browsers get more, dinosaurs get acceptable fallback. _I'm all for this approach in much wider terms than Nicole talks about._

Using Alphaimage loader added 100ms to Yahoo Search. Bear the Amazon financial data in in mind.

Crush your images. Two questions: Design. What quality do I need? Engineering. Squeeze the last bytes out of an image using crushing tool. Nicole is one of the creators of the non-lossy tool [Smush.it](http://smush.it) (now run by Yahoo).

_There's also [Smusher](http://github.com/grosser/smusher/tree/master) a ruby gem which you can use from the command line._

### #5 Avoid non standard browser fonts

Text in images will *never* be as performant as using browser compatible fonts. Stay away for anything but the rarest use. Not buttons, not all headings, not using PHP to generate images based on text.

_Think about [sIFR](http://wiki.novemberborn.net/sifr3/) too - plus that is my latest bugbear as I'm using [Clicktoflash](http://github.com/rentzsch/clicktoflash/tree/master.) Lots of great work currently being done with font-stacks and `@font-face`, although I'm not sure of the performance effects._

### #6 Use Columns Rather Than Rows

Vertical alignment is difficult in CSS. There isn't really a good performant way of doing it particularly if you're using JS.

### #7 Choose Your Bling Carefully

Every market is different. For example SEA users want one big page with everything! Some markets like lots of 'busy-ness'.

Take into account your market. Think about your constraints.

### #8 Be Flexible

Think about extensibility in height and width. Modules should be designed to take all the horizontal it can and it's content should control the height. Design for height changes in titles (browser text resize). Think of the future applications of your CSS code.

### #9 Learn to Love Grids

Very important, the grid allows reuse of components. Lots of performance freebies if you can reuse objects.

_I also have started to [describe content in a HTML5-style](http://mezzoblue.com/archives/2009/04/20/switched/) accross multiple sites which really helps with this component-style building._