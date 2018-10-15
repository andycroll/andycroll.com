---
title: A scope should return a scope
description: 'Simple code organisation can sometimes be enough.'
layout: article
category: ruby
image:
  base: '2018/a-scope-should-return-a-scope'
  alt: 'Coin-operated (tele)scope'
  source: 'https://unsplash.com/photos/K40awqK-hTI'
  credit: 'Laurenz Kleinheider'
---

The more you can stay on the ‘rails’ when coding Ruby on Rails applications the easier your life will be when maintaining the apps you’re building.

A good way of doing this is to try and stick to the patterns set out in the standard Rails APIs. One of the patterns you can use is to encompass regularly used queries as [scopes](https://guides.rubyonrails.org/active_record_querying.html#scopes).

## Instead of…

...using methods inside your scopes that return an object.

```ruby
class Message < ActiveRecord
  scope :sent, -> { where.not(sent_at: nil) }
  scope :recently_sent, -> { sent.order(sent_at: :desc) }
  scope :most_recently_sent, -> { recently_sent.first } # returns an object or nil
end
```


## Always…

...return an `ActiveRelation` from a named scope.

```ruby
class Message < ActiveRecord
  scope :sent, -> { where.not(sent_at: nil) }
  scope :recently_sent, -> { sent.order(sent_at: :desc) }

  def most_recently_sent
    recently_sent.first
  end
end
```


## But why?

This change improves the organisation of your code, rather than changing how you’ll use your models

When you call `.where` or `.order` it returns an Active Relation ‘scope’ that can be chained together with further scopes. You encourage flexibility and reuse if you maintain this behaviour where all of your own named scopes are able to be chained with others.


### Why not?

You _can_ get by by just being careful which scopes you use together, there is no “rule” against using `.first` or `.last` inside a scope.

This is just a helpful heuristic to organise your code to guide your, or your co-workers, future use of the scopes you create.
