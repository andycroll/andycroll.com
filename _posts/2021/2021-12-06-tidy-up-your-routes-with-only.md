---
title: "Tidy Up Your Routes with Only"
description: "Tidy routes are happy routes"
layout: article
category: ruby
image:
  base: "2021/tidy-up-your-routes-with-only"
  alt: "Road Closed. Diversion. Road signs."
  credit: "Ben Wicks"
  source: "https://unsplash.com/photos/zwN1MwCtR5Y"

---

It is easy with [Rails’ syntax for defining routes](https://guides.rubyonrails.org/routing.html) to make more URLs in your application available than you might intend to.


## Instead of…

…using an open `resources` block in your routes:

```ruby
resources :orders do
  resources :products
end
```

## Use…

…the `only` and `except` options to limit the actions you’re generating:

```ruby
resources :orders, except: %w[destroy] do
  resources :products, only: %w[show]
end
```


## Why?

This is all about clarity, tidying up, and protecting against unexpected errors or security holes.

Primarily the issue is that in the default, unrestricted, case all seven default routes are created. If a user calls a route that is defined but not used, Rails will attempt to call the relevent controller action, even if it doesn’t exist. This can lead to errors or, worse, unexpected behaviour.

Rails’s standardised naming (while great for our code organisation and structure) means routes can be guessed. The presence of a `GET /orders/12345` route pointing to `orders#show` would imply the existance of a `GET /orders` route for `orders#index`, and more dangerously a `PUT /orders/12345` route for `orders#update`.

Minimising the generated routes is another step in maintaining a secure, organised codebase.

In extremely large codebases, where there are a lot of routes with this issue, you _might_ see a performance improvement by creating fewer routes, but you'd need a _very_ big application before this will even be worth thinking about.


## Why not?

This might not be a severe issue for your application. The benefits, purely from organisational perspective, means it's worth casting an eye over your `config/routes.rb` file.