---
title: "For clarity merging hashes use with_defaults"
description: "A hash merge, but backwards for readability"
layout: article
category: ruby
image:
  base: "2023/for-clarity-merging-hashes-use-with_defaults"
  alt: "Two people standing on a merging hill road"
  credit: "Pine Watt"
  source: "https://unsplash.com/photos/birds-eye-view-photo-of-two-people-standing-on-gray-concrete-road-in-front-of-hill-dUbKcgu0zjw"

---  

Rails is known for adding methods to existing core Ruby classes for improved readability via Active Support. One such example is the `with_defaults` method on `Hash`. This method is an alias of another added method `reverse_merge`, which should give you a clue as to how it works.

As you can see in [the source code](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/hash/reverse_merge.rb#L14), the implementation is fairly straightforward.


## Instead of…

...using `Hash#merge` when adding defaults...

```ruby
user_provided = {q: "Andy", age: 44, limit: 1}

listing_options = {order: "asc", limit: 25}.merge(user_provided)
#=> {:order=>"asc", :limit=>1, :q=>"Andy", :age=>44}
```


## Use…

...the `#with_defaults` method.

```ruby
user_provided = {q: "Andy", age: 44, limit: 1}

listing_options = user_provided.with_defaults(order: "asc", limit: 25)
#=> {:order=>"asc", :limit=>1, :q=>"Andy", :age=>44}
```



## Why?

This "simple" method exists because in web applications we're often dealing with configuration or optional arguments passed to methods.

Using `with_defaults`, as opposed to Ruby's `merge`, improves readability. The resulting code is clearer to understand and maintain as the method name is clearer as to its intention.

Rails contains many examples of this sort of syntactic improvement, use of "idiomatic" Rails code was the rationale for adding this alias in [the initial PR](https://github.com/rails/rails/pull/28603).

With the `with_defaults` method, it's clear that the original hash's values are prioritised, the default values are secondary and thus deemphasised.


## Why not?

Some folks object to this implicit "monkey patching" of Ruby core classes by the Rails framework.

However, if you're working in a Rails codebase, objecting to the framework's practical decisions (and taste) might be making things harder for yourself.

In addition, previous patches from Rails have—due to their Ruby-ness—been made part of Ruby itself. The syntax and readability of a method like this definitely feels like it falls into that category.