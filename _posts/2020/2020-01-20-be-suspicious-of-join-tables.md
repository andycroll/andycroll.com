---
title: "Be Suspicious of Join Tables"
description: "They're probably hiding a concept you haven’t named yet"
layout: article
category: ruby
image:
  base: '2020/be-suspicious-of-join-tables'
  alt: Welding
  credit:  Max LaRochelle
  source: "https://unsplash.com/photos/QzP1GcDOSC8"

---

We often have to represent many-to-many relationships between models in our applications. Rails provides a method in its migrations to generate a table in your database to support this. You can see the documentation in the [Rails guide for ActiveRecord migrations](https://guides.rubyonrails.org/active_record_migrations.html#creating-a-join-table).

However, these basic join tables often obscure a useful concept in your application that might be better represented as a named model.


## Instead of...

...using a join table:

#### Migration

```ruby
create_join_table :user, :organisation
```

#### `app/models/user.rb`

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :organisations
end
```

#### `app/models/organisation.rb`

```ruby
class Organisation < ApplicationRecord
  has_and_belongs_to_many :users
end
```

## Use

...a real model and name the concept that the join table is hiding.

#### Migration

```ruby
create_table :memberships do |t|
  t.references :user
  t.references :organisation
end
```

#### `app/models/membership.rb`

```ruby
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organisation
end
```

#### `app/models/user.rb`

```ruby
class User < ApplicationRecord
  has_many :memberships
  has_many :organisations, through: :memberships
end
```

#### `app/models/organisation.rb`

```ruby
class Organisation < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships
end
```


## Why?

Almost without fail, whenever a join model sits for any length of time in an application it begins to acquire behaviour. It’s nearly always worth having a first pass at naming the concept that the join model represents.

With a “basic” join table there is no way to add functionality to this unnamed concept. The lack of a place to put this extension means you might have to attach functionality to one of the joined models.

In the “join table” example above you might be forced to put a `role` attribute on the `User`, where a `User`’s role is likely different for each organisation of which they're a member. This need—for role information that belongs on the join table—demonstrates the requirement for a real `Membership` model.

Delaying the creation of the `Membership` concept will make for more refactoring later.


## Why not?

There's extra manual work, if you aren’t using the built-in functionality for "has and belongs to"-style joins, so you have to create the joining model yourself.

```ruby
# has_and_belongs_to_many
user = User.create!(email: "andy@goodscary.com")
user.organisations.create!(name: "One Ruby Thing")

# real model
user = User.create!(email: "andy@goodscary.com")
organisation = Organisation.create!(name: "One Ruby Thing")
Membership.create!(user: user, organisation: organisation)
```

This extra work during creation is partially because you don’t get the same [convenience methods from `has_and_belongs_to_many`](https://api.rubyonrails.org/v6.0.2.1/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many). You do get a similar selection of association methods by using the `has_many: xx through: yy` syntax. You can review the different generated methods in [the documentation for Active Record associations](https://api.rubyonrails.org/v6.0.2.1/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many).

You can build a quick join model to get going and explore the domain of your application. But be ready to change the table into a ‘proper model’ when you start to discover attributes or logic that really belong to the join.
