---
title: Replace Timecop With Rails’ Time Helpers in RSpec
description: You can use the built-in functionality
layout: article
category: ruby
image:
  base: '2019/replace-timecop-with-rails-time-helpers-in-rspec'
  alt: 'Jean-Claude Van Damme as Max Walker'
  source: ''
  credit: ''
---

Time-sensitive tests can be a pain.

Thankfully, for many years the `timecop` gem served as a way to “freeze” time and “time travel” during tests, so that any time that elapsed during the running of your tests did not affect the results.

It’s such a good idea that Rails built very similar functionality into Active Support, [released in Rails 4.1](https://guides.rubyonrails.org/v5.0/4_1_release_notes.html#active-support-notable-changes).


## Instead of…

…using `timecop` in your Rails projects:

### `Gemfile`

```ruby
group :test do
  gem "timecop"
end
```

### Your tests

```ruby
describe "some set of tests to mock" do
  before do
    Timecop.freeze(Time.local(1994))
  end

  after do
    Timecop.return
  end

  ### your tests here
end
```


## Use…

…the built-in Rails helpers.

### `spec/support/time_helpers.rb`

```ruby
RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
```

### Your tests

```ruby
describe "some set of tests to mock" do
  before do
    travel_to Time.local(1994)
  end

  after do
    travel_back
  end

  ### your tests here
end
```


## But why?

Freezing time can be useful if you ever find yourself testing times or dates used inside your app. As your tests run, real time elapses and this can sometimes lead to tests where the expected result and actual value can be seconds apart.

Given that Rails has included these helpers, there’s no reason to use `timecop` as you’d be adding a dependency for functionality that’s already been provided by the framework.


### Why not?

If you’re outside of a Rails application, perhaps writing a gem or using another framework, you won't have access to these helpers without manually including Active Support, so `timecop` is still a brilliant choice.

Even inside a Rails application you might choose to use the `timecop` gem as it has some slightly enhanced functionality over the Active Support helpers.

It contains methods to [change the speed at which time passes](https://github.com/travisjeffery/timecop#timecopscale), which my be useful if your application needs something to happen as time passes. For example, if you need to check whether an email is sent out within an hour, you don’t want to sit there waiting for the actual time to pass.
