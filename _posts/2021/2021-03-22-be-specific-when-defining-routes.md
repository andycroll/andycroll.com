---
title: "Be specific when defining your routes"
description: "Reduce accidental paths and be intentional"
layout: article
category: ruby
image:
  base: "2021/be-specific-when-defining-your-routes"
  alt: "Purple-lit urban road junction"
  source: "https://unsplash.com/photos/_QoAuZGAoPY"
  credit: "Denys Nevozhai"
---

Many controllers don't need the full set of restful routes. We often have a resource that can only be created and deleted or where there's only a show action.


## Instead of ...

...generating all the routes.

### `config/routes.rb`

```ruby
resources :dogs do
  resources :meals
end
```


## Use...

...only the routes you're actually going to use

### `config/routes.rb`

```ruby
resources :dogs, only: %w[create edit index new show update] do
  resources :meals, only: %w[create index]
end
```


## Why?

There's no value to maintaining, generating and loading routes that do not link to actions in your controllers. In fact it'll allow errors to creep into your code and unexpected behaviour to live on in your application.

If a user can't `destroy` a `Thing` in a `ThingsController, don't give them a route to try and do so.


## Why not?

It might be faster at the point of creation to just leave all those superflouous routes around, but it feels like a poor decision for the maintainability of your app.
