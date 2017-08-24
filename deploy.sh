#!/usr/bin/env bash
set -ev # halt script on error

bundle
bundle exec jekyll build
s3_website push
