---
title: "Order by created_at and updated_at with a concern"
description: "If you sort models by timestamps regularly, this is nice"
layout: article
category: ruby
image:
  base: "2021/order-by-created-and-updated-with-a-concern"
  alt: "Food Truck Festival ’ drive-by’"
  source: "https://unsplash.com/photos/1SjD5ZEiUsA"
  credit: "Micheile Henderson"
---

Rails provides `scopes` as a way to encapsulate your regularly used queries. I've suggested before that it's a good idea to [keep calls to the query API within models](/ruby/only-use-named-scopes-ouside-models/).

Rails also includes [Active Support's concerns](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html) as a way to group functionality that's used in multiple places. It's a wrapper around a standard Ruby `module`.

We're often sorting models in our applications by the time they are created or updated, using the [built-in timestamps](https://api.rubyonrails.org/classes/ActiveRecord/Timestamp.html).

Let's see how to combine these techniques to provide a useful mini library in our application.


## Rather than...

...ordering by timestamps using scopes:

### `app/controllers/books_controller.rb`

```ruby
class BooksController
  def index
    @books = Book.order(created_at: :asc).limit(20)
  end
end
```

Or, better, using a named scope:

### `app/models/book.rb`

```ruby
class Book < ApplicationRecord
  scope :by_recently_created, -> { order(created_at: :desc) }
end
```

### `app/controllers/books_controller.rb`

```ruby
class BooksController
  def index
    @books = Book.by_recently_created.limit(20)
  end
end
```


## Use...

...this handy concern:

### `app/models/concerns/orderable_by_timestamp.rb`

```ruby
module OrderableByTimestamp
  extend ActiveSupport::Concern

  included do
    scope :by_earliest_created, -> { order(created_at: :asc) }
    scope :by_recently_created, -> { order(created_at: :desc) }
    scope :by_earliest_updated, -> { order(updated_at: :asc) }
    scope :by_recently_updated, -> { order(updated_at: :desc) }
  end
end
```

### `app/models/book.rb`

```ruby
class Book < ApplicationRecord
  include OrderableByTimestamp
end

```

### `app/controllers/books_controller.rb`

```ruby
class BooksController
  def index
    @books = Book.by_recently_created.limit(20)
  end
end
```

And you can reuse the `OrderableByTimestamp` in multiple models, now you have the scopes extracted into a concern.


## Why?

This shows the magic of the different parts of Rails working together to perform a common refactor.

This refactor uses these useful features of Rails to extract regularly reused functionality into one place. You might see this referred to as [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)-ing up your code.


## Why not?

Including four fairly generic scopes into multiple models, if you don't use every scope, might be expanding the model unnecessarily. This is a reason to keen any concerns you build as small as you can.
