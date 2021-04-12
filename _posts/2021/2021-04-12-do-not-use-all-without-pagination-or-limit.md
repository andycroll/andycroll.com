---
title: "Do not use .all without pagination or a .limit"
description: "You might not regret it now, but one day, maybe?"
layout: article
category: ruby
image:
  base: "2021/do-not-use-all-without-pagination-or-limit"
  alt: "Books on the wall of FIKA cafe in Toronto"
  source: "https://unsplash.com/photos/Oaqk7qqNh_c"
  credit: "Patrick Tomasso"
---

One of the first things you learn in Rails is how to load all of the objects of a certain model from the database to be displayed in an index view.

## Be wary of...

...ever using a "raw" `.all`:

```ruby
class MoviesController
  def index
    @movies = Movie.all
  end
end
```


## Use...

...either a `limit` scope or pagination gem.

```ruby
class MoviesController
  def index
    @movies = Movie.limit(50)
  end
end

# using pagination
class MoviesController
  include Pagy::Backend

  def index
    @movies = pagy(Movie.all, items: 50, page: params[:page])
  end
end
```

My preferred pagination gem is [`pagy`](https://github.com/ddnexus/pagy). It has a relatively small and understandable core, works well across frameworks, and is very performant.


## Why?

Lots of coding is an exercise in avoiding situations where you can shoot yourself in the foot. This is one of those times.

Even if the limit is pretty large (50? 100?), having one puts a cap on the outcome of any unexpected situation. At most you'll only ever load and then render a fixed, known, number of Active Record objects.


## Why not?

You might think a quick use of `.all` will be of little harm, but it may cause a performance issue at some point.

Perhaps you feel in control because you're dealing with a model that customers cannot create more instances of. Perhaps the relevant view isn't hit by many customers. It is _still_ worth limiting your potential downside with this defensive technique.
