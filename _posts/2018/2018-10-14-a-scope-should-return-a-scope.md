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

The more you can stay on the ‘rails’ when coding Ruby on Rails application the easier you life will be when maintaining the apps you’re building.

A good way of doing this is to try and stick to the patterns set out in the standard Rails APIs.

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

...return an `ActiveRelation` from a scope.

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

This is more a case of code organisation rather than any change in how you’ll actual use your models.

When you call `.where` or `.order` it returns an Active Relation ‘scope’ that can be chained together with further scopes. You encourage flexibility and reuse if you maintain this behaviour where your own named scopes are able to be chained with others.


### Why not?

This is just a helpful heuristic to organise your code. If you don't feel the organisational benefit, simply don’t use it.
