---
title: "Use GitHub Actions for Rails CI with Postgres"
description: "Updated for 2021: So many commits to get here"
layout: article
category: ruby
image:
  base: '2019/github-actions-ci-for-rails-with-postgresql'
  alt: 'Green Octocat testing'
redirect:
  - ruby/github-actions-ci-for-rails-with-specific-ruby-versions
  - ruby/github-actions-ci-for-rails-with-postgresql-11-and-structure-sql
---

Writing tests alongside your software is strongly recommended. It helps you protect against bugs, reduces the fear of scary deploys, and can even help you develop better software.

The Ruby and Rails community have always had a strong focus on testing. Typically that means having some sort of “continuous integration” system constantly running your test suite.

There’s a bunch of good choices, but recently GitHub launched [Actions](https://github.com/features/actions) (in beta), which lets you run arbitrary workflows, including tests, after certain things happen within your git repository.


## Instead of...

...using a separate CI service,


## Use...

...GitHub Actions to run your Rails tests.

### `.github/workflows/tests.yml`

```yml
name: Tests

on:
  pull_request:
    branches:
      - 'main'
  push:
    branches:
      - 'main'

jobs:
  build:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
    - uses: actions/checkout@v2

    - uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true

    - name: Install PostgreSQL client
      run: |
        sudo apt-get -yqq install libpq-dev

    - name: Build App
      env:
        PGHOST: localhost
        PGUSER: postgres
        PGPASSWORD: postgres
        RAILS_ENV: test
      run: |
        bin/rails db:setup

    - name: Run Tests
      env:
        PGHOST: localhost
        PGUSER: postgres
        PGPASSWORD: postgres
        RAILS_ENV: test
      run: |
        bundle exec rake test
        bundle exec rake test:system
        # or Rspec
        # bundle exec rspec
```


## Why?

There is a benefit to your tests being in the ‘same place’ as your code. There is no separate account to maintain, no separate service to bill, and no separate team member administration.

GitHub Actions is completely free for public, open source, repositories. There’s also a pretty generous free tier for private repositories, and it is pretty economical after that.

It can also be configured to do many tasks other than just running your tests: automatic image compression, other code checks, notifications to other systems, adding comments, making assignments, doing deployments, and more. All you have to do is fight with the configuration. :-)


## Why not?

Your testing infrastructure should, as much as possible, reflect your production environment to help catch subtle bugs. For me, at work for [CoverageBook](https://coveragebook.com) & [AnswerThePublic](https://answerthepublic.com), that means using Heroku’s [pipelines, CI, and review apps](https://www.heroku.com/flow).

You might think that increased centralisation of your development infrastructure at one company is a risk, or that a different CI provider might offer higher levels of service or configurability if you have specific needs.

If you have a testing infrastructure that’s working well somewhere else, it probably isn’t worth the effort to move, although you could set up a parallel CI on GitHub to compare against your existing provider.


### Specific Ruby versions

Before [the `ruby/setup-ruby` action appeared](https://github.com/ruby/setup-ruby) you had to use `rvm` as GitHub only provides certain (sometimes outdated) versions of Ruby [in their architecture](https://docs.github.com/en/free-pro-team@latest/actions/reference/specifications-for-github-hosted-runners#supported-software) (scroll down for compatible versions) and it seems, from [this comment](https://github.com/actions/setup-ruby/issues/14#issuecomment-524020179), that releasing new CI images when Ruby is updated isn’t a priority.
