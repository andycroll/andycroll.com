---
title: "Read the .ruby-version into your Gemfile"
description: "A lovely little improvement to your life when upgrading Ruby"
layout: article
category: ruby
date: 2024-02-07
image:
  base: '2021/read-ruby-version-in-your-gemfile'
  alt: 'Falling white dice'
  credit:  Riho Kroll
  source: "https://unsplash.com/photos/m4sGYaHYN5o"


last_modified_at: 2024-02-07
---

Previously I recommended [using a loose version ruby version constraint in your Gemfile](/ruby/use-loose-ruby-versioning-in-your-gemfile/). This is still a valuable technique, but here’s another useful variation that's works well for most of us, most of the time.

Hat tip to [Emma](https://twitter.com/EmmaBeynon) for the this one-liner.

Ruby version managers (such as [chruby](https://github.com/postmodern/chruby)) ensure an application uses a specific version of Ruby by looking for a [`.ruby-version` file](https://gist.github.com/fnichol/1912050) in the root directory of each app.

The file specifies the required version of Ruby for the application and the manager automatically switches the environment to use the specified version.

[The version can also be specified in your Gemfile](https://bundler.io/gemfile_ruby.html) using bundler, which is more often used to define the version of Ruby to use in a deployed application.


## Instead of...

...specifying your exact ruby version in two places and potentially generating conflicts:

```ruby
# Gemfile
ruby "3.0.0"
```

```ruby
# .ruby-version
3.1.2
```

This results in an error, as bundler checks the current version of Ruby specified in the `Gemfile`.

```
Your Ruby version is 3.0.0, but your Gemfile specified 2.7.2
```

## Prior to rubygems version 2.4.19 use...

...the fact that the `Gemfile` is simply another Ruby file:

```ruby
# Gemfile
ruby File.read(".ruby-version").strip
```

```ruby
# .ruby-version
3.1.2
```

## Actually use...

...the `file` argument.

```ruby
# Gemfile
ruby file: ".ruby-version"
```

```ruby
# .ruby-version
3.1.2
```

This enhancement was [released in August 2023](https://github.com/rubygems/rubygems/blob/master/bundler/CHANGELOG.md#2419-august-17-2023) here's the addition in [PR #6876](https://github.com/rubygems/rubygems/pull/6876) and there's been a couple of bug fixes too.

You _might_ need to run the following commands to get onto the latest rubygems and bundler for your application.

```shell
gem update --system
bundle update --bundler
```


## Why?

This means that when you upgrade Ruby you only need to update in one place: the `.ruby-version` file.

Most of us, most of the time, are happy to specify a version of Ruby for all environments and this is a cool micro-improvement that reminds us that the `Gemfile` is just another ruby script!


## Why not?

There are still services where the availability of new Ruby versions are delayed so the prevous [loose ruby version technique](/ruby/use-loose-ruby-versioning-in-your-gemfile/) might be a better fit for your project.


## Also

If you're using [ASDF](https://asdf-vm.com) for multiple tool management (rather than solely a ruby version manager), the `file:` argument supports `.tool-versions` files too.

That functionality was added in [version 2.4.20](https://github.com/rubygems/rubygems/blob/master/bundler/CHANGELOG.md#2420-september-27-2023) in September 2023 via [PR #6898](https://github.com/rubygems/rubygems/pull/6898)