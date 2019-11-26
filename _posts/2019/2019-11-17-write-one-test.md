---
title: "Write One Test"
description: "Much, much better than none"
layout: article
category: ruby
image:
  base: '2019/write-one-test'
  alt: 'Smoke'
  credit: 'Pascal Meier'
  source: 'https://unsplash.com/photos/1uVCTVSn-2o'

---

Rails comes with a built-in testing framework and many Rubyists evangelise various methods of testing: Behaviour Driven Development, 100% test coverage, Red-Green-Refactor.

But perhaps you’ve never really ‘got it’ or ever seen the benefits of an established testing culture. As a result you might not have _any_ tests in your Rails application.


## Instead of...

...not having any tests:


## Perhaps...

...just write _one_ “smoke” test.

### `test/system/home_page_test.rb`

```ruby
class HomePageTest < ApplicationSystemTestCase
  test "show homepage" do
    visit "/"
    assert_text "Text on your homepage"
  end
end
```

You can run this test by typing `bundle exec rails test:system`.


## Why?

This single test does two major things.

One, because it is a ‘system test’ using a real browser to test your entire site, it checks that your application builds, runs successfully and displays a homepage to the world. This has value.

Two, now you’ve taken your first step into testing, you can take more.


## Why not?

For me, it’s a case of: why stop here? Once you have this basic smoke test, you can add a simple test to check that sign up of new users works. Or that signing in an existing user works.

These sorts of simple, but full system, tests will give you a surprising amount of benefit for very little ongoing effort.

These kinds of system tests rarely allow you to test all the permutations of sophisticated logic within your application. Those sorts of things are better tested in unit tests. For general “is my application mostly working”-type concerns, you'll get a lot of milage (and coverage) out of these broad smoke tests.
