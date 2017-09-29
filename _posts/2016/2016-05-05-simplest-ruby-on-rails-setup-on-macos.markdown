---
title: 'Simple Ruby/Rails Setup on macOS'
description: 'A super-light Rails setup for modern macOS'
layout: article
category: ruby
redirect_from:
  - /mac/ruby/the-simplest-possible-serious-ruby-on-rails-setup-on-mavericks/
  - /2014/01/15/the-simplest-possible-serious-ruby-on-rails-setup-on-mavericks/
  - /mac/ruby/simplest-ruby-on-rails-setup-on-macos/
image: '2016/simplest-ruby-on-rails-setup-on-macos'
imagealt: 'Mac laptop'
imagecredit: 'Photo by [chuttersnap](https://unsplash.com/photos/alCEnNmzhPE) on Unsplash'
---

I try and keep my development environment as 'light' as possible, so with that in mind here's my serious (in that I make a living from coding) but simple Ruby and Rails setup for a Mac.

The reason for writing this? Managed to nuke my machine's install and thus had an opportunity to review my toolkit.

## Homebrew

[Homebrew](http://brew.sh) is better than Macports in nearly every way. Open source recipes to manage stuff you used to have install yourself.

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You'll want to install some dependancies. You'll also need gcc on modern macOS to install rubies younger than 2.0.

```shell
brew install gdbm libffi libyaml openssl readline
brew install gcc48
```

This then makes installing the rest, super easy.

## chruby

[chruby on github](https://github.com/postmodern/chruby)

I'm a bit fan of the simplest thing that can possibly work. This library is the latest in a line from rvm through rbenv to easily manage multiple ruby versions on your development machine.

```shell
brew install chruby
```

So good it caused the authors of other 'simple ruby managers' to retire their projects.

### ruby-install

[ruby-install](https://github.com/postmodern/ruby-install) is used for installing your Rubies. Good name, no?

```shell
brew install ruby-install
```

### Install some Rubies

```shell
ruby-install ruby 2.3
ruby-install ruby 2.4
```

shellAdd the following lines to your `~/.bash_profile` as described in the chruby readme.

    source /usr/local/share/chruby/chruby.sh
    source /usr/local/share/chruby/auto.sh
    chruby ruby-2.4

First line enables chruby, second line auto-switches rubies for each project you have based on a `.ruby-version` (a cross ruby installer convention) and the third line selects your default ruby.

## Local Database

I'm all about the Heroku deployment, so I use PostgreSQL locally as well. It's good practice to use the same DB type and version in development as you do in production.

```shell
brew install postgres
brew services start postgresql
```

## Rails itself

You'll want bundler and rails as a bare minimum.

```shell
gem install bundler
gem install rails
```

## Let's Roll

Now to get going you can:

```shell
rails new yourapplicationname -d postgres
cd yourapplicationname
```

It is good practice to include a `.ruby-version` file in the root of your app. It'll look like this if you're on the latest version of ruby.

```ruby
2.4.2
```

But otherwise, job done.

```shell
bundle
bundle exec rails server
```

And navigate to [http://localhost:3000](http://localhost:3000).

-----

### There's a script for that?

I do have a few scripts that I try and keep maintained that let me quickly setup a development machine.

[andycroll/macsetup on github](https://github.com/andycroll/macsetup) if you're interested.
