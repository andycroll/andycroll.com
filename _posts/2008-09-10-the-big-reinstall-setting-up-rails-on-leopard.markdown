---
title: "The Big Reinstall, Setting Up Rails on Leopard"
layout: post
---

**Note** This is probably way out of date.

Having had a [disaster](/2008/09/09/the-data-disaster-get-backups-now) with my MacBook, I've spent the best part of a day getting my work environment how I want it. Here's the Rails-y bit!

## The Basics

    sudo gem update --system
    sudo gem update rails

Err. Latest Rails.

## XCode

You need XCode to get all the 'compile-y' goodness that Mac OS X can provide. You can get it from your Leopard Install disk or from [Apple Developer Connection](http://developer.apple.com/technology/xcode.html) (it is a 1GB download and you'll need to sign up to ADC though). Some Gems need it (passenger for one) to build.

## Git

I was installing this manually before but you can just grab a [pre-compiled package](http://code.google.com/p/git-osx-installer/.

## MySQL

You can use [Dan Benjamin's instructions](http://hivelogic.com/articles/2007/11/installing-mysql-on-mac-os-x) but again I [go the cheats route](http://dev.mysql.com/downloads/mysql/5.0.html#macosx-dmg).

## Testing - RSpec

I'm an [RSpec](http://rspec.info) man, after many hours of painful learning, if you still use Test:Unit you can skip the first command but the latter two are useful anyway for autotest and colourising test output.

    sudo gem install rspec
    sudo gem install ZenTest
    sudo gem install redgreen

## CocoaMySQL

Very Useful to manage your development databases... [download from Sourgeforge](http://cocoamysql.sourceforge.net/) (doesn't that sound retro now?)

## Capistrano

You don't plan to FTP your files do you?

    sudo gem install capistrano

## TextMate

If you're a rails-head you'll need [TextMate](http://macromates.com/), plus here are the commands to get the latest versions of the bundles for the main software you'll be using.

You'll probably want the [ProjectPlus Extension](http://ciaranwal.sh/2008/08/05/textmate-plug-in-projectplus) too.

I'm assuming you've installed a fresh TextMate here...

    mkdir ~/"Library/Application Support/TextMate/Bundles/"
    cd ~/"Library/Application Support/TextMate/Bundles/"

### [Ruby on Rails Bundle](http://drnicwilliams.com/2008/01/31/get-ready-for-the-textmate-trundle-to-rails-20-bundle/)

    git clone git://github.com/drnic/ruby-on-rails-tmbundle.git [Ruby on Rails.tmbundle"
    cd "Ruby on Rails.tmbundle"
    git checkout --track -b two_point_ooh origin/two_point_ooh
    git pull

### [RSpec Bundle](http://github.com/dchelimsky/rspec-tmbundle/wikis)

    git clone git://github.com/dchelimsky/rspec-tmbundle.git RSpec.tmbundle

### [Git Bundle](http://gitorious.org/projects/git-tmbundle)

    git clone git://gitorious.org/git-tmbundle/mainline.git Git.tmbundle

### Code Highlighting

I like [Vibrant Ink](http://alternateidea.com/blog/articles/2006/1/3/textmate-vibrant-ink-theme-and-prototype-bundle) or Ryan Bates' [RailsCasts](http://github.com/ryanb/textmate-themes/tree/master)

## Apache and Passenger

I use the built in Apache and passenger to serve my Rails apps locally, rather than having to script/server everytime I change projects.

    sudo gem install passenger

And follow the instructions to complete the installation.

You'll also need to nip to System Preferences and switch on Web Sharing.

### Virtual Hosts

I also use a [hosts widget](http://www.apple.com/downloads/dashboard/networking_security/hostswidget.html) and edit my Apache config to get nice addresses like dev.deepcalm.com or tgafootball.local so I can run several sites at the same time.

    mate /etc/apache2/httpd.conf

...to open the config file. On line 464, uncomment...

    Include /private/etc/apache2/extra/httpd-vhosts.conf

...then save and exit. Now...

    mate /private/etc/apache2/extra/httpd-vhosts.conf

...and add the following for each site...

    <VirtualHost *:80>
        DocumentRoot "/Users/andy/Sites/sitedir"
        ServerName sitename.local
    </VirtualHost>

...and make sure you add the "sitename.local" to point at 127.0.0.1 in the widget I linked to earlier. When you add a new site you'll need to restart Apache by deselecting and reselecting the Web Sharing in System Preferences or typing...

    sudo apachectl restart

## All done

That's what I've done so far... I've abandoned [Growl](http://growl.info/) again for being too distracting, but we'll see, I may reinstall.

I think I'm ready to do real work again now!


