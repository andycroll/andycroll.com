---
title: "Group Repeated Options with with_options"
description: "Use with_options to apply shared options to validations, associations, callbacks, or routes."
layout: article
category: ruby
date: 2026-03-03 06:00
image:
  base: "2026/with-options-group-shared-config"
  alt: "Organized kitchen drawer with dishes and cups neatly arranged"
  credit: "Orgalux"
  source: "https://unsplash.com/photos/a-drawer-with-dishes-and-cups-inside-of-it-2RKhuWvrpIc"
---

When multiple validations share the same `if:` condition, or multiple callbacks share the same `only:` constraint, you end up repeating yourself. `with_options` groups them together.

## Instead of...

...repeating conditions across multiple validations:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true, if: :published?
  validates :body, length: { minimum: 100 }, if: :published?
  validates :author, presence: true, if: :published?
end
```

## Use...

...the `with_options` method to group common configurations:

```ruby
class Article < ApplicationRecord
  with_options if: :published? do
    validates :title, presence: true
    validates :body, length: { minimum: 100 }
    validates :author, presence: true
  end
end
```

Works well in controllers too:

```ruby
class AdminController < ApplicationController
  with_options only: [:edit, :update] do
    before_action :require_admin
    before_action :set_audit_trail
  end
end
```

And associations:

```ruby
class User < ApplicationRecord
  with_options dependent: :destroy do
    has_many :posts
    has_many :comments
    has_many :likes
  end
end
```

## Why?

`with_options` merges the given options into every method call inside the block. In the validation example, `if: :published?` gets added to each `validates` call automatically.

This syntax groups related configuration visually—it's immediately clear these rules only apply to published articles. If you have to change the condition; it is only once, not three times.

Works in routes too:

```ruby
with_options controller: "admin/reports" do
  get "daily", action: :daily
  get "weekly", action: :weekly
  get "monthly", action: :monthly
end
```

See the [with_options documentation](https://api.rubyonrails.org/classes/Object.html#method-i-with_options) for details.

## Why not?

With only two items, the block adds more lines than it saves. Three or more is where `with_options` starts to pay off.

Nesting multiple `with_options` blocks gets hard to follow. If you find yourself nesting, reconsider.
