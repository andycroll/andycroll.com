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

We often need to access a parameter from the URL that isn't part of the regular rails routes. Something passed after

A ruby `Hash` is typically accessed using square brackets, like `hash[key]`, but you can also use the method `fetch`, like `hash.fetch(key)`.


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

If you access an item from the `params` hash directly or have built this sort of private method it implies that the hash contains a required value for the correct functioning of your action.

Using `fetch` means the Hash will not return `nil` and stop you getting a misleading `NilClass` error somewhere else. You _want_ the code to raise an exception, a `KeyError`, if the params are missing the value you need.

Or you might be doing a `nil` check when later using this parameter in your controller action.

NB: This is different from Rails’ [Strong Parameters]. (Which are also a separate, but good idea).


##  Why not?

You might take a view that the increased visual complexity and possible errors are not worth it.

If the value isn’t required or you fall back to default you might want to use the `#fetch` syntax with a block.

```ruby
params.fetch[:important_and_required] { 'default' }
```
