---
title: "Assign a default value to an attribute in Active Record"
description: "You’ve probably been using callbacks. Don’t."
layout: article
category: ruby
image:
  base: '2023/assign-default-to-an-attribute-active-record'
  alt: "Blank wood"
  credit: "Keith Misner"
  source: "https://unsplash.com/photos/h0Vxgz5tyXA"

---

If you ever needed to set a default value in an instance of an Active Record model, you probably used a callback.

Since Rails 5.0 there’s [been a better way](https://edgeguides.rubyonrails.org/5_0_release_notes.html#active-record-attributes-api). I had missed it until recently! (Thanks [Moses](https://twitter.com/Gathukumose/status/1615298667031797760)!)


## Instead of…

…assigning a default value in a callback:

```ruby
class Message
  before_validation :assign_delivered_at

  # ...

  private

  def assign_delivered_at
    delivered_at ||= Time.zone.now
  end
end
```


## Use…

…the Attribute API from Active Record:

```ruby
class Message
  attribute :delivered_at, default: -> { Time.zone.now }

  # ...
end
```


## Why?

Callbacks can be confusing to understand even when there's a good reason to use them. Generally, the less you use them the fewer surprises you’ll have at a later date.

The `attribute` syntax is terser, clearer and _the way_ Rails recommends to execute this behaviour.

There’s a lot more going on [in this API](https://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html)—attribute changes tracking, type casting, adding attributes not backed by the database—but in this case we’re only using the default-setting capability.


## Why not?

Ideally, from a data integrity perspective, it'd be better to set these defaults in the database schema.

Setting a default at the database level means Active Record will pull that value into a new, unsaved, model, so you’d be unlikely to need this approach.

Additionally, beware that setting a default in the Active Record model, as shown earlier, will _overwrite_ any default set in the database when you call `Model.new`. Unless you're deliberately looking to change the default when using Rails you don’t need to specify one using the Attribute API as well.
