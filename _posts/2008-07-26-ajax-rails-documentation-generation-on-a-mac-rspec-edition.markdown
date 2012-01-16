---
title: "Ajax Rails Documentation Generation on a Mac (Rspec edition)"
layout: post
---

I've been a great fan of better searchable Ruby and Rails documentation, such as [GotAPI](http://gotapi.com) and [Railsbrain](http://railsbrain.com,) and have taken to having a copy of the railsbrain and rubybrain docs locally served on my macbook (for those moments where I'm disconnected from the Internet). Plus the style used by the normal RDoc is just disgusting. Frames? Eww.

So I wanted to have the same for Rspec, the other key tool I use in day-to-day Rails development. The [source for the generator](http://github.com/breakpointer/ajax-rdoc/) by the [author of railsbrain](http://CollectiveNoodle.com/) is up on github.

So to install on a Mac (OS X Leopard) do the following in the terminal...

    git clone git://github.com/breakpointer/ajax-rdoc.git ~/ajax-rdoc

...then copy the generator to the right place...

    sudo cp ~/ajax-rdoc/rdoc/generators/ajax_generator.rb /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/rdoc/generators

...and copy the formatting templates too...

    sudo cp -R ~/ajax-rdoc/rdoc/generators/template/ajax /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/rdoc/generators/template

...and you're done.

Then simply go into the directory you wish to make documentation of and type...

    rdoc --fmt ajax

In my case I wanted the Rspec docs, so went into the vendor/plugins/rspec/lib directory and presto, instant JS-powered documentation. Now if only I could be bothered to write a script to update these automatically...
