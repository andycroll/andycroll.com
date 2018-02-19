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

Last time we discussed using the hash-style syntax in your `#where` methods but in my examples I did something I wouldn't do in my real-life code...

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

And then use them like so:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.published
  end
end
```


## But why?

This technique improves the organisation of your code. It forces you to do two things that can really help keep you productive over time.

Firstly: naming the concepts you're creating. When you name something aptly, you explain it, often for the benefit of “future you” or your colleagues.

Secondly: you have _one_ place to look for all of this. If you define scopes outside your models you can end up with arbitrary scopes and conditions defined all over your code base. When you know where all the conditions are defined you'll know where to look when you want to refactor or optimise database performance.


## Why not?

For scopes involving `#limit`, simple `#order`s or pagination, there's very little point in bothering to create specific scopes, as the syntax of the `ActiveRelation` methods are quite succinct.

Naming scopes is only beneficial when you gain extra clarity. Sometimes, with non-`#where` queries, there is no enhanced understanding from wrapping simple `ActiveRelation` methods inside a scope.

```ruby
scope :by_title, -> { sort(:title) } # no benefit?
scope :by_updated_at, -> { sort(:updated_at) } # terrible name
scope :recently_updated, -> { sort(updated_at: :desc) } # probably worth doing
```

It's worth bearing in mind that a named scope might still be a good choice for complex ordering or if the sorting is closely related to the conditions specified in a `#where` query.

A good heuristic to creating a named scope with ordering or limits is: can I easily name the concept? Is the result better than the existing `ActiveRelation` methods?
