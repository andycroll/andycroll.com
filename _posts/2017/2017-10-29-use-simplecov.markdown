---
title: 'Use simplecov in your Rails test suite'
description: 'It’s not a silver bullet, but it is useful.'
layout: article
category: ruby
image:
  base: '2017/use-simplecov'
  alt: 'Coverage HTML output'
---

A useful way of assessing the effectiveness of your testing is to use the [`simplecov` gem](https://github.com/colszowka/simplecov) with your Rails application. It counts the number of times each line of application code is run during your test suite.

## Use…

…`simplecov` in your tests.

#### Add to `Gemfile`

```ruby
group :test do
  gem 'simplecov', require: false
end
```

And run `bundle` in the root directory of your project.

#### Add to `.gitignore`

Do not commit generated files in the `coverage` directory.

```
coverage/*
```

#### Add to top of `spec/spec_helper.rb` or `test/test_helper.rb`

```ruby
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/' # for rspec
  add_filter '/test/' # for minitest
end
```
Add this right at the top of the file. The `add_filter` lines means files matching the passed string are excluded from the results.

Then run your tests as normal, you'll see a message that looks like:

```
Coverage report generated for RSpec to /PATH_TO_YOUR_APP. 584 / 1068 LOC (54.68%) covered.
```


## But why?

Having an awareness of your level of coverage is useful as an input to understanding the stability of your application and protection against regressions.

Exploring the generated HTML reports (available in `coverage/index.html`) is a good way to see if there are areas of your code that are poorly tested.

It's important to note that measuring your test coverage of your application’s code is a blunt instrument. In fact, aiming for 100% coverage is not a noble aim, or even useful.

<blockquote class="blockquote pl-3">
  <p class="mb-0">Some codebases with 100% test coverage will still have bugs, and some codebases with much lower coverage will not.</p>
  <footer class="blockquote-footer">@sarahmei <cite title="Source Title"><a href="https://twitter.com/sarahmei/status/819270166576058369">11 Jan 2017</a></cite></footer>
</blockquote>


## Why not?

It could slow your test suite a little. But it's only, at most, additional seconds in a multiple-minute test suite.
