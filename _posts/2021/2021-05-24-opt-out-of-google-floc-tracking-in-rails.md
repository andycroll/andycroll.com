---
title: "Opt out of Google’s FLoC User Tracking in Rails"
description: "FLoC Off"
layout: article
category: ruby
image:
  base: "2021/opt-out-of-google-floc-tracking"
  alt: "V for Vendetta-style Guy Fawes masks"
  source: "https://unsplash.com/photos/RlLP5fUh2m0"
  credit: " Ahmed Zayan"
last_modified_at: 2021-06-24
---

Google has recently built user tracking directly into Chrome. This new technology is named [Federated Learning of Cohorts](https://blog.google/products/chrome/privacy-sustainability-and-the-importance-of-and/) (shortened to <abbr title="Federated Learning of Cohorts">FLoC</abbr>).


## Instead of...

doing nothing...


## Add...

...a custom response header to opt your application, and thus your users, out of this user tracking.

### `config/application.rb`

```ruby
# ...
module YourAppName
  class Application < Rails::Application
    # ...
    config.action_dispatch.default_headers["Permissions-Policy"] = "interest-cohort=()"
    # ...
  end
end
```


## Why?

The [<abbr title="Electronic Frontier Foundation">EFF</abbr>](https://www.eff.org) has a detailed breakdown of [why FLoC is a bad idea](https://amifloced.org) as well as a way to check if you’re included in their initial roll out.

In short, it's not just bad because advertisers can track you around the Internet (still creepy after all these years!) but also because Google are leveraging their dominance in the browser market to further entrench their advertising monopoly.

The core Wordpress team are considering [treating FLoC like a security concern](https://make.wordpress.org/core/2021/04/18/proposal-treat-floc-as-a-security-concern/) and Wordpress powers over two-fifths of the Internet, so you’ll be in good company.

You might also might want to personally switch to Safari or Firefox or similar, even for your web development needs.


## Why not?

Maybe you don’t mind about advertising tracking your users around the internet, which is a reasonable position.

That said... you don't have to be a privacy absolutist to see that Google’s effective monopoly is somewhat an issue for even companies that use and pay for search or display adverts.


## Extras

You can also [add the FLoC opt-out header if you are deploying a Jekyll site on Netlify](/ruby/opt-out-of-google-floc-tracking-on-netlify).
