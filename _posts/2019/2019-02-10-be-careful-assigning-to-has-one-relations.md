---
title: Be Careful Assigning to has_one Relations
description: Strange Think
layout: article
category: ruby
image:
  base: '2019/be-careful-assigning-to-has-one-relations'
  alt: 'Broken net'
  source: "https://unsplash.com/photos/IV--3UEiHlI"
  credit: "Ben Hershey"
---

For much of the time, when building relationships between models you typically use `has_many` and `belongs_to`. There are some circumstances where a `has_one` relationship is more appropriate.

However, the behaviour of `has_one` has some wrinkles in its behaviour that make it a little trickier to deal with. See the side-effects of the generated `#association=` method [in the Rails documentation](https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one).


## When…

…assigning an invalid new object means you lose the relationship with the currently related model.

```ruby
class Biography < ApplicationRecord
  belongs_to :person, optional: true

  validates :text, presence: true
end

class Person < ApplicationRecord
  has_one :biography
end

person = Person.create(name: "Andy Croll")
=> #<Person id: 1, name: "Andy Croll" ...>
person.create_biography(text: "Writes emails")
=> #<Biography id: 1, person_id: 1, text: "Writes emails" ...>
person.biography = Biography.new
=> #<Biography id: nil, person_id: 1, text: nil ...>
person.reload.biography
=> nil
```

Oh my.


## Use…

…a transaction to wrap the deletion of the existing object. Only delete the existing related object if the new object is valid.

```ruby
class Biography < ApplicationRecord
  belongs_to :person, optional: true

  validates :text, presence: true
end

class Person < ApplicationRecord
  has_one :biography

  def replace_biography(attributes = nil)
    Person.transaction do
      biography&.destroy!
      create_biography!(attributes)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
    biography # returns invalid object
  end
end

person = Person.create(name: "Andy Croll")
=> #<Person id: 1, name: "Andy Croll" ...>
person.create_biography(text: "Writes emails")
=> #<Biography id: 1, person_id: 1, text: "Writes emails" ...>
person.replace_biography
=> #<Biography id: nil, person_id: 1, text: nil ...>
person.reload.biography
=> #<Biography id: 1, person_id: 1, text: "Writes emails" ...>
```

Boom.


## But why?

The `has_one` relation has always had this behaviour. In the first example the assignment (in this case via `#biography=`) to the `has_one` attribute, removes the previously joined model at the database level even if the newly assigned model isn't valid.

When this happened in our app, my coworkers and I were surprised!

The method created in the second solution, uses the `!` variants of the `create` and `destroy` methods inside a transaction to raise exceptions and rollback both changes if either fails.


### In Modern Rails 5.2

It’s trickier to shoot yourself in the foot in Rails after version 5.2 due to the default behaviour of `belongs_to` also including a validation. In the examples I used the `optional: true` argument to make the `Person` class behave like pre-5.2 Rails.

When the framework attempts to set the `person_id` attribute to `nil` in Rails 5.2 a `ActiveRecord::RecordNotSaved` error is raised that prevents the assignation even if the new record is valid.

The (slightly inelegant) solution above would also work in a default Rails 5.2 `belongs_to` relationship.


### Why not?

There’s a solid argument that using `has_one` has more weird edges than the more typical `has_many` relationship.

You could try and re-engineer the logic of your application to use that relationship, which might make for more predictable behaviour.


### Thanks..

..to [Sean Griffin](https://twitter.com/sgrif), Rails Committer [#11](https://contributors.rubyonrails.org), for a sense check of this approach.
