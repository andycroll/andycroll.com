---
title: 'Avoid Writing SQL When Using ActiveRelation'
description: 'It's fine, but prefer not to if you can.'
layout: article
category: ruby
image:
  base: '2018/avoid-writing-sql-when-using-activerelation'
  alt: 'Coding SQL'
  source: 'https://unsplash.com/photos/fPkvU7RDmCo'
  credit: 'Caspar Rubin'
---

ActiveRelation, which powers the searching and querying engine of ActiveRecord, is a powerful and flexible tool.

## Instead of...

...writing literal SQL snippets inside an ActiveRelation `#where` method.

```ruby
class Screenshot < ApplicationRecord
  scope :visible, -> where('automated_screen_grab = ? AND hidden_at IS NULL', true)
end
```


## Use...

...the hash-style syntax.

```ruby
class Screenshot < ApplicationRecord 
  scope :visible, -> where(automated_screen_grab: true, hidden_at: nil)
end
```


## Why?

Both methods are valid and the “string with interpolated values” version was the _only_ way before ActiveRelation. The hash-style gives you more flexibility.

In this example when you use the “hash style” syntax the resulting SQL includes the table name. When passing strings to `#where` the resulting SQL only includes the literal string you pass in, so no table names.

This flexibility means you can reuse that scope from other classes without worry that a similarly named.

For example given:

```ruby
class Website < ApplicationRecord
  has_many :screenshots
end
```

You could use the following to get to visible websites that have visible screenshots.

```ruby
Website.where(hidden_at: nil).include(:screenshots).where(Screenshot.visible)
```

This would not work with the string version.

## Why not?

I could be argued that using the ActiveRelation hash syntax _also_ allows you to have statements that could be portable between database adapters.

The portability of the statements, which only really occur in more complex examples, isn’t really a benefit. No one _really_ moves their database between Postgres and MySQL once they’re in production. Not unless they like pain.

This is also a very simple example. There are times when you might find a string representation in `#where` method is the only option and that’s totally fine. But if there’s an option, why not build some flexibility into your scopes.
