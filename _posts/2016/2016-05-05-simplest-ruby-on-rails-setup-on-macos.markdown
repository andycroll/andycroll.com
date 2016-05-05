---
title: 'Simplest (Serious) Ruby/Rails Setup on MacOS'
layout: post
category:
  - mac
  - ruby
redirect_from:
  - /mac/ruby/the-simplest-possible-serious-ruby-on-rails-setup-on-mavericks/
  - /2014/01/15/the-simplest-possible-serious-ruby-on-rails-setup-on-mavericks/
---

I try and keep my development environment as 'light' as possible, so with that in mind here's my serious (in that I make a living from coding) but simple Ruby and Rails setup for a Mac.

The reason for writing this? Managed to nuke my machine's install and thus had an opportunity to review my toolkit.

## Homebrew

[Homebrew](http://brew.sh) is better than Macports in nearly every way. Open source recipes to manage stuff you used to have install yourself.

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You'll want to install some dependancies. You'll also need gcc on Mavericks to install rubies younger than 2.0.

```
brew install gdbm libffi libyaml openssl readline
brew install gcc48
```

This then makes installing the rest, super easy.

## chruby

[chruby on github](https://github.com/postmodern/chruby)

I'm a bit fan of the simplest thing that can possibly work. This library is the latest in a line from rvm through rbenv to easily manage multiple ruby versions on your development machine.

```
brew install chruby
```

So good it caused the authors of other 'simple ruby managers' to retire their projects.

### ruby-install

[ruby-install](https://github.com/postmodern/ruby-install) is used for installing your Rubies. Good name, no?

```
brew install ruby-install
```

### Install some Rubies

```
ruby-install ruby 2.2
ruby-install ruby 2.3
```

You might have some old 1.9 projects hanging around, but it's worth upgrading given support for 1.9.3 is long gone.

```
ruby-install ruby 1.9 -- CC=gcc48
```

Add the following lines to your `~/.bash_profile` as described in the chruby readme.

    source /usr/local/share/chruby/chruby.sh
    source /usr/local/share/chruby/auto.sh
    chruby ruby-2.1

First line enables chruby, second line auto-switches rubies for each project you have based on a `.ruby-version` (a cross ruby installer convention) and the third line selects your default ruby.

## Local Database

I'm all about the Heroku deployment, so I use PostgreSQL locally as well. It's good practice to use the same DB in development as you do in production.

```
brew install postgres
```

## Rails itself

You'll want bundler and rails as a bare minimum.

```
gem install bundler
gem install rails
```

## Let's Roll

Now to get going you can:

```
rails new yourapplicationname -d postgres
cd yourapplicationname
```

It is good practice to include a `.ruby-version` file in the root of your app. It'll look like this if you're on the latest version of ruby.

```
2.3.1
```

But otherwise, job done.

```
bundle
bundle exec rails server
```

And navigate to [http://localhost:3000](http://localhost:3000).

-----

## One last extra... still aiming at simple

### Pow

I also like pow to auto-serve my apps in a low maintenance way. It also lets you use [xip.io](http://xip.io) to test your other devices with your local webserver.

```
gem install powder
powder install
```

In every app you want to add (your zero-configuration web server) pow... you need to configure (!) a .powrc file with the following contents [as detailed in the chruby wiki](https://github.com/postmodern/chruby/wiki/Pow). You can also check it into source control.

```
source /usr/local/share/chruby/chruby.sh
chruby $(cat .ruby-version)
```

And then type:

```
powder link
powder open
```

... in the directory of the app.

### There's a script for that?

I do have a few scripts that I try and keep maintained that let me quickly setup a development machine.

[andycroll/macsetup on github](https://github.com/andycroll/macsetup) if you're interested.
