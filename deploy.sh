#!/usr/bin/env bash
set -e # halt script on error
bundle exec jekyll build
s3_website push
