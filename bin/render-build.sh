#!/usr/bin/env bash
set -o errexit

bundle install

if [[ "${IS_PULL_REQUEST}" == "true" ]]; then
    echo "Preview: building with --future"
    JEKYLL_ENV=production bundle exec jekyll build --future
else
    echo "Production build"
    JEKYLL_ENV=production bundle exec jekyll build
fi
