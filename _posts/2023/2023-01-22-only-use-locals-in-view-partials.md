---
title: "Only use locals in view partials"
description: "It helps keep your state manageable"
layout: article
category: ruby
image:
  base: '2023/only-use-locals-in-view-partials'
  alt: "Local building sign"
  credit: "Priscilla Du Preez"
  source: "https://unsplash.com/photos/acNPOikiDRw"

---

The Rails view layer, the main way our users and customers access our work, is incredibly flexible, but it can easily become tricky to manage.

https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials

Many Ruby teams 

## Instead of…

…accessing instance variables inside partials:

```ruby
# calling the partial
<%= render "user_email" %>

# inside the _user_email.html.erb partial
<%= @user.email %>
```


## Use…

…local variables to pass in context:

```ruby
# calling the partial
<%= render partial: "user_email", locals: { user: @user } %>

# inside the _user_email.html.erb partial
<%= user.email %>
```


## Why?

This is primarily a good practice for better maintenance and organisation in more complex projects. Rails explicitly allows a vast global scope in its view environment, but many experienced developers (including me) have got themselves in trouble by reaching outside of a partial for a variable.

Additionally, by not using instance variables or helper methods (like `current_user` or Rails’s CurrentAttributes) within your partials you make them more reliably cache-able, because the values you’re passing into them will be all the context required to build a cache key. Without this it would be possible to accidentally serve a cached partial with incorrectly-scoped data.

For example:

```ruby
# calling the partial
<%= render partial: 'things/thing', collection: @things, cached: true %>

# things/_thing.html.erb partial
<%= thing.name %>
<%= link_to "Edit", edit_thing_path(thing) if @user.admin? %>
```

Multiple users will get the same partial pulled from the cache, either with the link to “Edit” or without, depending on which user rendered the page first. In addition you might not want the non-admin users to see the link, exposing a potential security hole.


## Why not?

There’s no _harm_ in using your globally scoped powers, if you’re careful. One of the benefits of using Rails when you first learn is it’s flexibility and ability to just _do stuff_. However as a project continues this flexibility is one of [Rails’s "sharp knives"](https://rubyonrails.org/doctrine#provide-sharp-knives), useful but easy to cut yourself.

With judicious and comprehensive testing (which you might want anyway) you can protect against the sort of issues you might see above.


#### Recommendation

View partials, unless very well marshalled, can get disorganised and “messy” very quickly. Even when you’re using them without assuming global state.

You might want to consider, on larger projects, reaching for some kind of component system. The main solution in the Rails world for this is [ViewComponent](https://viewcomponent.org/) which is used at Github. There’s also the [Phlex](https://www.phlex.fun/) library which is under very active development.
