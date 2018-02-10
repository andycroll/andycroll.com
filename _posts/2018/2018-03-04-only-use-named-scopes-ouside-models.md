---
title: 'Only use named scopes outside models'
description: 'Keep your wheres to yourself'
layout: article
category: ruby
image:
  base: '2018/only-use-named-scopes-outside-models'
  alt: 'San Francisco Museum of Modern Art'
  source: 'https://unsplash.com/photos/RkJF2BMrLJc'
  credit: 'William Bout'
---

Last time we discussed using the hash-syntax in your where clauses but in my examples I did something

## Instead of…

...using `#where` scopes in your controllers or views.

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.where(status: 'published')
  end
end
```


## Use…

...only named scopes that you define in your model.

```ruby
class Post < ApplicationRecord
  scope :published, -> { where(status: 'published') }
end
```

And then use it like:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.published
  end
end
```


## But why?

This technique is mostly to improve the organisation of your code. It forces you to do two things that can really help keep you productive over time.

Firstly, naming the concepts you're creating. When you name something you explain it, often for the benefit of “future you”.

Secondly, there's _one_ place to look for all this rather than having arbitrary scopes and conditions defined all over your code base. When you know where all the conditions are defined you'll know where to look when you want to refactor or optimise database performance.


## Why not?

There are exceptions to this. I tend not to bother with `#limit` in scopes or simple `#order`s. Or pagination (if you're doing that).

These scopes are less generic than the `#where` conditions and naming them does often enhance understanding. Plus there's no real clarity benefit as the APIs for those classes are pretty straightforward.

It's worth bearing in mind that a named scope might still be a good choice for complex ordering or if the sorting is closely related to the conditions specified in a `#where` method.

A good heuristic to using a scope with ordering is 'can I name the concept'.

```ruby
scope :by_title, -> { sort(:title) } # no benefit?
scope :recently_updated, -> { sort(updated_at: :desc) } # worth doing
```
