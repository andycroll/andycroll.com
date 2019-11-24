---
title: "Ensure you correctly build your caching keys"
description: "Why won't this model update? Oh."
layout: article
category: ruby
image:
  base: '2019/ensure-you-correctly-build-caching-keys'
  alt: 'Keys'
  credit:  Chunlea Ju
  source: "https://unsplash.com/photos/8fs1X0JFgFE"

---

Caching is a hugely powerful tool in maintaining performance of often requested pages and partials in your application.

It can also be a cause of confusing behaviours (mostly “stuff not updating on the page”) when you test your app in a production environment.

Rails has great built-in support for view fragment caching. The framework includes an elegant way of invoking and busting the cache based on the model `id`, it’s `updated_at` timestamp and an automatically generated digest of the specific view template. You can find more details in the [Rails guide on caching](https://guides.rubyonrails.org/caching_with_rails.html#fragment-caching).


## Instead of...

...just using the modal key in your key:

```ruby
class Event < ApplicationRecord
  has_many :attendees
end

class Attendee < ApplicationRecord
  belongs_to :event
  has_many :prerequistes
end

class Prerequistes < ApplicationRecord
  belongs_to :attendee

  scope :done, -> { where.not(completed_at: nil) }
end
```


### `app/views/events/show.html.erb`

```erb
<% @event.attendees.each do |attendee| %>
  <% cache [attendee] do %>
    <p>
      <%= attendee.name %>, <%= @event.name %><br />
      <small>
        <%= attendee.prerequistes.done.count %> done
      </small>
    </p>
  <% end %>
<% end %>
```


## Use

...a combined key, including the parent object

```ruby
class Event < ApplicationRecord
  has_many :attendees
end

class Attendee < ApplicationRecord
  belongs_to :event, touch: true
  has_many :prerequistes
end

class Prerequistes < ApplicationRecord
  belongs_to :attendee, touch: true
  scope :done, -> { where.not(completed_at: nil) }
end
```

### `app/views/events/show.html.erb`

```erb
<% @event.attendees.each do |attendee| %>
  <% cache [@event, attendee] do %>
    <p>
      <%= attendee.name %>, <%= @event.name %><br />
      <small>
        <%= attendee.prerequistes.done.count %> done
      </small>
    </p>
  <% end %>
<% end %>
```


## Why?

This is a ‘powerful tools enabling subtle bugs’ problem.

Models that `belong_to` other models can often have a context. When we use the data from any “parent” model in a view-cached partial, you need to include that model in the cache key, or the view will not update with changes to that model.

Additionally also be aware of nested models. If a model `has_many` objects and you neglect to use `touch: true` in the declaration of the “child” model’s `belongs_to` relationship then the cache key won’t change and you’ll see out of date information.


## Why not?

It’s always worth checking whether you need caching at all. It is best to understand the performance improvements versus the possibility of maddeningly hard to find bugs.

Caching bugs aren't apparent in the normal places we look for bugs; the code, the logs and in error reporting. Also your tests are unlikely to discover them as caching is typically turned off in development and test environments.

I’m definitely not saying “don’t cache” I'm just saying “be careful”.
