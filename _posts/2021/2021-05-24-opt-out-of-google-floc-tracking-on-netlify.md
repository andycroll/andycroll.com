---
title: "Opt out of Google’s FLoC User Tracking on Netlify"
description: "Seriously FLoC Off"
layout: article
category: ruby
image:
  base: "2021/opt-out-of-google-floc-tracking"
  alt: "V for Vendetta-style Guy Fawes masks"
  source: "https://unsplash.com/photos/RlLP5fUh2m0"
  credit: " Ahmed Zayan"
---

Google has recently built <abbr title="Federated Learning of Cohorts">FLoC</abbr> user-tracking into Chrome.

I covered how to [opt out of FLoc in a Ruby on Rails application](/ruby/opt-out-of-google-floc-tracking-in-rails) but a few of my sites—including this use [Jekyll](https://jekyllrb.com), hosted on [Netlify](https://netlify.com).


## Add...

...a [custom response header](https://docs.netlify.com/routing/headers/) to your Netlify configuration.

### `netlify.toml`

```toml
[[headers]]
  for = "/*"
  [headers.values]
    Permissions-Policy = "interest-cohort=()"
```

## Or...

... a specific headers file.

### `_headers`

```
/*
  Permissions-Policy: interest-cohort=()
```

For Jekyll you'll need to add the following to ensure the the headers configuration ends up in the folder you are deploying.

### `_config.yml`

```yml
# ...
include: [_headers]
# ...
```


## Why? Why not?

I covered the “why” in the [original article](/ruby/opt-out-of-google-floc-tracking-in-rails#why).

