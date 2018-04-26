---
title: 'Use Hash#fetch when using Rails params in controllers'
description: ''
layout: article
category: ruby
image:
  base: '2018/use-hash-fetch-when-using-params-in-controllers'
  alt: 'Retriever'
  source: 'https://unsplash.com/photos/Pzu9f6Nby5w'
  credit: 'Mitchell Orr'
---

We often need to access a parameter from the URL that isn't part of the regular Rails routes. For example, the query parameter in `/search?q=term`.

The parameters for a Rails action are stored in an `ActionController::Parameters` object which behaves quite a bit like a standard Ruby hash.

A Ruby hash is typically accessed using square brackets, like `hash[key]`, but you can also use the method `fetch`, like `hash.fetch(key)`.


## Instead of…

...accessing required parameters from the `params` hash using the typical `#[]` method...

```ruby
class ThingController < ApplicationController
  # ... actions

  private

   def an_important_param
     params[:important_and_required]
   end
end
```


## Use…

...the `#fetch` method to raise an error if the required parameter is missing.

```ruby
class ThingController < ApplicationController
  # ... actions

  private

   def an_important_param
     params.fetch(:important_and_required)
   end
end
```


## But why?

Needing to access an item from the `params` object implies that the value is important for the correct functioning of your action.

If you attempt to access a value using the `#[]` method and the relevant key is missing, Ruby will return `nil`. This might lead to `NilClass` errors if you try and use the result later on.

Using `#fetch` means the hash will not return `nil` in the case of a missing key. Instead it'll raise a `KeyError`. You _want_ the code to raise an exception where the error happens, at the point where the data is missing.


##  Why not?

You might take a view that you simply like the look of the regular `#[]` hash syntax. After all, it is shorter. But you must be willing to deal with the errors.

If you're using a parameter in this way you might also consider changing the route to include it. You _could_ make your search route `/search/term` rather than `/search?q=term`.

Note that you can use `#fetch` to provide a default value:

```ruby
params.fetch(:important) { 'default' }
```

This would also help avoid lots of checking for `nil` in the code where you use the value.
