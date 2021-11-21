---
title: "Tidy Up Your Routes with Only"
description: "Be tidy"
layout: article
category: ruby
image:
  base: "2021/tidy-up-your-routes-with-only"
  alt: "Road Closed. Diversion. Road signs."
  credit: "Ben Wicks"
  source: "https://unsplash.com/photos/zwN1MwCtR5Y"

---

It is easy with [Rails’ syntax for defining routes](https://guides.rubyonrails.org/routing.html) to open up more URLs in your application than you might intend.


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

This is a case where it is all about clarity, tidying up and pretecting against unexpected errors or security holes.

Primarily the issue is that in the default non-restricted case the seven default routes are created. If the correct path and method are passed into your application by a user, Rails will atempt to call the relevent controller action, even if it doesn’t exist, which will lead to errors.

There’s also the chance of security holes. Rails’ standardised naming (while great for our code organisation and structure) means routes can be guessed. The presence of a `GET /orders/12345` route pointing to `orders#show` would imply the existance of a `GET /orders` route for `orders#index` and more dangerously a `PUT /orders/12345` route for `orders#update`.

It’s quite easy to shoot yourself in the foot with a combination of overly permissive routes and  confusing authenticated and public “read only” actions. Minimising the generated routes is another step in maintaining a secure, organised codebase.

In extremely large code base where there’s a lot of routes wiht this issue, you _might_ see an improvement in speed from creating less routes, but you'd need a _very_ big application.


## Why not?

This might not be a severe issue for your application. The benefits from a pure organisational persepctive means it's worth casting an eye over your `config/routes.rb` file.