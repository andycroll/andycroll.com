---
title: "Read the .ruby-version into your Gemfile"
description: "A lovely little improvement to your life when upgrading Ruby"
layout: article
category: ruby
image:
  base: '2021/read-ruby-version-in-your-gemfile'
  alt: 'Falling white dice'
  credit:  Riho Kroll
  source: "https://unsplash.com/photos/m4sGYaHYN5o"

---

Previously I recommended [using a loose version ruby version constraint in your Gemfile](/ruby/use-loose-ruby-versioning-in-your-gemfile/). This is still a valuable technique, but here’s another useful variation that's works well for most of us, most of the time.

Hat tip to [Emma](https://twitter.com/EmmaBeynon) for the this one-liner.

Ruby version managers (such as [chruby](https://github.com/postmodern/chruby)) ensure an application uses a specific version of Ruby by looking for a [`.ruby-version` file](https://gist.github.com/fnichol/1912050) in the root directory of each app.

The file specifies the required version of Ruby for this application and the manager automatically switches the environment to use the specified version.

[The version can also be specified in your Gemfile](https://bundler.io/gemfile_ruby.html) using bundler, which is more often used in a deployed environment.


## Instead of...

...specifying your exact ruby version in two places and potentially generating conflicts:

```ruby
# Gemfile
ruby "2.7.2"
```

```ruby
# .ruby-version
3.0.0
```

This results in an error, as bundler checks the current version of Ruby.

```
Your Ruby version is 3.0.0, but your Gemfile specified 2.7.2
```

## Use

...the fact that the `Gemfile` is simply another Ruby file:

```ruby
# Gemfile
ruby File.read(".ruby-version").strip
```

```ruby
# .ruby-version
3.0.0
```


## Why?

This means that when you upgrade Ruby you can make the change once, in the `.ruby-version` file.

Most of us, most of the time, are happy to specify a version of Ruby for all environments and this is a cool micro-improvement that reminds us that the `Gemfile` is just another ruby script!


## Why not?

There are still services where the availability of new Ruby versions are delayed so the prevous [loose ruby version constraint](/ruby/use-loose-ruby-versioning-in-your-gemfile/) might be a better fit for your project.
