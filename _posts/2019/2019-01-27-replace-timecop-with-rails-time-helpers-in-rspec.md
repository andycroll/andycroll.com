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

Thankfully for many years the `timecop` gem served as a way to “freeze” and “time travel” during tests, so that time elapsing during your tests doesn't effect the results.

It’s such a good idea, that Rails built very similar functionality into Active Support [released in Rails 4.1](https://guides.rubyonrails.org/v5.0/4_1_release_notes.html#active-support-notable-changes).


## Instead of…

…using `timecop` in your Rails projects

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

…use the built-in Rails helpers.

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

Freezing time can be useful if you ever find yourself testing times or dates used inside your app. As your tests run, real time elapses and this can sometimes lead tests where values might be (incorrectly) seconds apart.

Why to use the Active Support functionality over `timecop`?

Broadly speaking there is a one-to-one mapping between the gem and Rails’ functionality. There’s rarely a need to include duplicate functionality to that built into Rails.



### Why not?

If you’re outside of a Rails application, perhaps writing a gem or using another framework, you won't have Active Support already loaded so `timecop` is still a brilliant choice.

Even inside a Rails application you might choose to use the `timecop` gem as it has some slightly enhanced functionality over the Active Support helpers. It contains methods to [change the speed of time](https://github.com/travisjeffery/timecop#timecopscale) passing which might be useful if you’re application has some “real” time behaviour.
