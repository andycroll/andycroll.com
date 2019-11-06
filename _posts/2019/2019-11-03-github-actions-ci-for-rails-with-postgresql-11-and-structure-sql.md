---
title: "Use GitHub Actions for Rails CI with Postgres 11 & structure.sql"
description: "More config required for SQL"
layout: article
category: ruby
image:
  base: '2019/github-actions-ci-for-rails-with-postgresql'
  alt: 'Green Octocat testing'
---

This article is a follow-up to [Using GitHub Actions for Rails CI with Postgres](/ruby/github-actions-ci-for-rails-with-postgresql).

A little extra configuration is required to run your tests against PostgreSQL 11 if you dump your [database schema as SQL](https://edgeguides.rubyonrails.org/active_record_migrations.html#types-of-schema-dumps), i.e. use `structure.sql` rather than `schema.rb`.

### `.github/workflows/tests.yml`

```yml
name: Rails Tests using structure.sql

on:
  pull_request:
    branches:
      - 'master'
  push:
    branches:
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

    - name: Install PostgreSQL 11 client required for loading structure.sql
      run: |
        sudo apt update
        sudo bash -c "echo deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main >> /etc/apt/sources.list.d/pgdg.list"
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
        sudo apt-get update
        sudo apt-get -yqq install libpq-dev postgresql-client-11

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
