---
title: "Use Loose Ruby Versioning in Your Gemfile"
description: "The tiniest little improvement to your life"
layout: article
category: ruby
image:
  base: '2019/use-loose-ruby-versioning-in-your-gemfile'
  alt: 'Red numbered dice'
  credit:  Terry Vlisidis
  source: "https://unsplash.com/photos/vPQbo1D7Eco"

---

Patch level versions (e.g. 2.6.**3**) of Ruby are compatible with each other and often only include bug fixes and security patches. Significant upgrades to the Ruby language that include new syntax or features, and make bigger changes to the language, are released once a year—as a gift for us all—on Christmas Day.

Many developers ensure their application use a specific version in development by using a “Ruby version manager”, like [rvm](https://rvm.io) or, my preferred choice, [chruby](https://github.com/postmodern/chruby).

These version managers look for a [file](https://gist.github.com/fnichol/1912050) in the root directory of each app called `.ruby-version`. The file specifies the correct version of Ruby for this application and then switches the local environment, switching between multiple installed versions of Ruby automatically.

You can also [specify your Ruby version in your Gemfile](https://bundler.io/v1.12/gemfile_ruby.html) using bundler, which is more often used in your deployment environment.


## Instead of...

...specifying your exact ruby version in two places and potentially generating conflicts.

```ruby
# Gemfile
ruby "2.6.3"
```

```ruby
# .ruby-version
2.6.5
```

This results in an error, as bundler checks the current version of Ruby.

```
Your Ruby version is 2.6.5, but your Gemfile specified 2.6.3
```

## Use

...use loose versioning in the `Gemfile`

```ruby
# Gemfile
ruby "~> 2.6"
```

```ruby
# .ruby-version
2.6.5
```


## Why?

This comes down to a preference for ‘just enough’ flexibility in the `Gemfile`.

You can generally upgrade between 2.6.3 and 2.6.5 without expecting any changes to how your programme works.

I’ve found that having a flexible `Gemfile` Ruby has helped when deploying to environments that pre-build specific patches of Ruby and might not be as completely up to date with the latest patch versions of Ruby as soon as they are released.

Examples of this behaviour are Github Actions or Netlify.

The flexible constraint in the `Gemfile` prevents you from having to interrupt your deployment or CI process, whilst being able to upgrade your local Ruby versions.

You also only have to update your specific version in one place when you do make a change.

Additionally, with the flexible constraint, your deployment environment will automatically upgrade your Ruby version, on the next deploy, as it provides a more secure patch-level version.


## Why not?

It's totally fine to specify the full version. This is a micro-optimisation for most use cases.
