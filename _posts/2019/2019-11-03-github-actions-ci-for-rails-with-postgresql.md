---
title: "Use GitHub Actions for Rails CI with Postgres"
description: "So many commits to get here"
layout: article
category: ruby
image:
  base: '2019/github-actions-ci-for-rails-with-postgresql'
  alt: 'Green Octocat testing'

---

Writing tests when writing software is strongly recommended, it helps you protect against bugs and inadvertent changes, reduce the fear of scary deploys and can even help you make better software in

The Ruby and Rails community have always had a strong focus on testing. Typically that means having some sort of “continuous integration” system constantly running your test suite.

There’s a bunch of good choices, but recently GitHub launched [Actions](https://github.com/features/actions) (in beta) which lets you run arbitrary workflows, including tests, when certain things happen to your git repository.

It does need a little extra configuration to run your tests using PostgreSQL (my SQL database of choice).


## Instead of...

...using a separate CI service.


## Use...

...Github Actions to run your Rails tests.

### `.github/workflows/tests.yml`

```yml
name: Rails Tests

on:
  pull_request:
    - 'master'
  push:
    - 'master'

jobs:
  build:

    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:11.5
        ports: ["5432:5432"]
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5

    steps:
    - uses: actions/checkout@v1

    - name: Set up Ruby 2.6
      uses: actions/setup-ruby@v1
      with:
        ruby-version: 2.6.x

    - name: Install PostgreSQL 11 client
      run: |
        sudo apt-get -yqq install libpq-dev

    - name: Build App
      env:
        PGHOST: localhost
        PGUSER: postgres
        RAILS_ENV: test
      run: |
        gem install bundler
        bundle install --jobs 4 --retry 3
        bin/rails db:setup

    - name: Run Tests
      env:
        PGHOST: localhost
        PGUSER: postgres
        RAILS_ENV: test
      run: |
      bundle exec rake test
      bundle exec rake test:system
      # or Rspec
      # bundle exec rspec
```

If you use SQL dumps—you have a `db/structure.sql` file rather than a `db/schema.rb` file in your application—you’ll need to use [this slightly altered workflow](github-actions-ci-for-rails-with-postgresql-11-and-structure-sql).


## Why?

There is a benefit to your tests being in the ‘same place’ as your code. There is no separate account to maintain, no separate service to bill, no seperate ‘team member management’.

For limited usage it is _free_, even for private repositories, and pretty economical after that. And completely free for public, open source, repositories.

Github Actions can also be configured to do many tasks other than just running your tests. Automatic image compression, other code checks, notifications to other systems, adding comments, making assignments, doing deployments and more. All you have to do is fight with the configuration. :-)


## Why not?

Your testing infrastructure should, as much as possible, reflect your production environment to help catch subtle bugs. For me, at [work](https://coveragebook.com), that means using Heroku’s [pipelines, CI and review apps](https://www.heroku.com/flow), meaning our testing and QA infrastructure is as similar as we can make it to production.

You might also feel the idea of further centralisation of your development infrastructure with one company to be a risk. Or a different CI provider might offer you higher levels of service or configurability if you have specific needs.

If you have a testing infrastructure already set up somewhere else, potentially wound into a working system for deployment, it probably isn’t worth the effort to move.

There’s also a current issue with staying on the latest version of Ruby.
