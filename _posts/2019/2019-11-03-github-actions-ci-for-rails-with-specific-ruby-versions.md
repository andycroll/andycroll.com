---
title: "Use GitHub Actions for Rails CI with specific Ruby versions"
description: "You have to build from source or use a specific container"
layout: article
category: ruby
image:
  base: '2019/github-actions-ci-for-rails-with-postgresql'
  alt: 'Green Octocat testing'
---

This article is a follow-up to [Using GitHub Actions for Rails CI with Postgres](/ruby/github-actions-ci-for-rails-with-postgresql).

You’ll need to add extra steps to test against versions of Ruby not supported natively by GitHub Actions. This template uses [`rvm`](https://rvm.io) to install the version of Ruby specified in your `.ruby-version` file.

I'm indebted to the [rubygems repository](https://github.com/rubygems/rubygems/blob/master/.github/workflows/ubuntu-rvm.yml) for demonstrating the simplest way to do this.


### `.github/workflows/tests.yml`

```yml
name: Rails Tests with custom Ruby version

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

    - name: Set up RVM
      run: |
        curl -sSL https://get.rvm.io | bash

    - name: Set up Ruby from .ruby-version
      run: |
        source $HOME/.rvm/scripts/rvm
        rvm install $(cat .ruby-version) --binary
        rvm --default use $(cat .ruby-version)

    - name: Install PostgreSQL 11 client
      run: |
        sudo apt-get -yqq install libpq-dev

    - name: Build App
      env:
        PGHOST: localhost
        PGUSER: postgres
        RAILS_ENV: test
      run: |
        source $HOME/.rvm/scripts/rvm
        gem install bundler
        bundle install --jobs 4 --retry 3
        bin/rails db:setup

    - name: Run Tests
      env:
        PGHOST: localhost
        PGUSER: postgres
        RAILS_ENV: test
      run: |
        source $HOME/.rvm/scripts/rvm
        bundle exec rake test
        bundle exec rake test:system
        # or Rspec
        # bundle exec rspec
```
