---
title: Serving a Jekyll Blog using Heroku
description: 'Jekyll + Heroku = 💜'
layout: article
category: ruby
redirect_from:
  - /2014/01/19/serving-a-jekyll-blog-using-heroku/
image:
  base: '2014/serving-a-jekyll-blog-using-heroku'
  alt: 'Purple tinged Jekyll'
---

I've put up a few simple sites recently, for [upcoming][gembook] [books][herokubook] and a [bootstrapping mailing list][bootstrappingio], and these I've either used a *very* simple Sintra app, or in the case of a the more blogg-y sites, [Jekyll][jekyll], the simple Ruby blogging system.

[gembook]:/building-ruby-gems
[herokubook]:/ultimate-guide-to-rails-on-heroku
[bootstrappingio]:http://bootstrapping.io
[jekyll]:http://jekyllrb.com

I am unabashed in my love for Heroku for deploying Ruby. So how to get your Jekyll based blog onto Heroku? The are a few a few simple things. I'm all about doing the least to get something working. So in 10 lines of code (in 3 files) and 10 typed shell commands...

## Install the required gems

You need to download and install the [Heroku Toolbelt][toolbelt]. On a Mac I use [Homebrew] to install from the command line.

[toolbelt]:http://toolbelt.heroku.com
[homebrew]:http://brew.sh

```
brew install heroku-toolbelt
```

You'll also need Jekyll and bundler installed locally.

```
gem install jekyll bundler
```

## Make your blog

Using the `jekyll` command

```
jekyll new nameofyourblog
cd nameofyourblog
```

## Bundler

Create a file named `Gemfile` in the root of your new Jekyll project.

```
source 'https://rubygems.org'
ruby '2.1.0'
gem 'bundler'
gem 'jekyll'
gem 'rack-jekyll'
```

Now generate your bundle:

```
bundle
```

## Ignoring

You don’t want to have to generate your site and check it in before you deploy, let's remove our error-prone-selves from the process...

Create a `.gitignore` file with the following line, stopping your locally generated site from being committed.

```
_site
```

You also need to add the following line to the end of your `_config.yml` file to stop Jekyll including your configuration in it's generated site.

```
exclude: ['config.ru', 'Gemfile', 'Gemfile.lock', 'vendor']
```

## Serving the Site

This gem serves your app on Heroku using [RackJekyll][]. Create a file named `config.ru` in the root directory of your jekyll blog.

[rackjekyll]:https://github.com/adaoraul/rack-jekyll

```
require 'rack/jekyll'
run Rack::Jekyll.new
```

Because we're not committing the `_site` directory, it needs to be generated. So we use one of Heroku's splendid features... a Custom Build Pack

I've added the (very simple) commands to generate the `_site` directory on top of the [standard ruby build pack][rubybuildpack]. I'll also be keeping it up to date with the upstream changes while keeping my simple changes as the most recent commit (for clarity).

[rubybuildpack]:https://github.com/heroku/heroku-buildpack-ruby

So generate your new Heroku app...

```
heroku create nameofyourblog --buildpack https://github.com/andycroll/heroku-buildpack-jekyll.git
```

Then commit, and then push it up!

```
git add .
git commit -m 'first commit'
git push heroku master
heroku open
```

Nice. Now you might want to dive into the [Jekyll documentation][jekyll].
