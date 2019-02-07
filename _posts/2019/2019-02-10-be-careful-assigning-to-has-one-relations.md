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

Most of the time, when building relationships between models, you typically use `has_many` and `belongs_to`. There are some circumstances where a `has_one` relationship is more appropriate.

However, the behaviour of `has_one` has some quirks that make it a little trickier to deal with.

When you assign a new instance of a “contained” model to the `has_one` model the existing “contained” model is removed from the association and _causes a permanent change to be written to the database_. This happens whether the new model is valid or not.

Read about this side-effect of the generated `#association=` method [in the Rails documentation](https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one).


## Instead of…

…directly assigning a new object to a `has_one` object’s `#association=` method and being surprised by the side effects:

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

…a transaction to make sure the existing object is deleted only if the new object is valid.

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

The first example demonstrates that the assignment (in this case via `#biography=`) to the `has_one` attribute removes the previously associated model and writes to the database, _even if_ the newly assigned model isn't valid and will not save.

Normally when making assignments to an Active Record model, via a `#whatever=` method, the changes are not persisted to the database until you call `#save`. In this case, however, the change to the previously assigned model is written _at the point of assignment_.

The method I’ve created in the second solution uses the `!` variants of the `create` and `destroy` methods inside a transaction to raise exceptions and rollback both the unassignment of the existing model and assignment of the new one if either fails. This prevents subtle bugs and the unusual behaviour of implicit writing to the database.


### In Modern Rails (after 5.0)

In Rails 5.0, if you attempt to set the `person_id` attribute to `nil`, as the assignation of the new model will do, an `ActiveRecord::RecordNotSaved` error is raised. This prevents the assignation even if the new record is valid.

The model being removed from the association is no longer valid because `belongs_to` relationships now have an [implied presence validation](https://guides.rubyonrails.org/5_0_release_notes.html#active-record-notable-changes). The change in Rails’ behaviour happened in [this pull request](https://github.com/rails/rails/pull/18937).

I used the `optional: true` argument, in my example, to make the `Person` class behave like pre-5.0 Rails.

The solution I’ve proposed would also work in this more strict `belongs_to` relationship.


## Why not?

You can manage the `has_one` relationship in multiple other ways that do not wrap the whole task in a `replace_whatever`-style method such as I’ve suggested.

You could avoiding calling the `#whatever=` method in your code or allow assignment only when the association is empty... but you will need to manage it somehow.

There is a reasonable argument that using `has_one` leads to more edge cases than the more typical `has_many` relationship. One approach would be to engineer the logic of your application to use that relationship, which might make for more predictable behaviour.


### Thanks..

..to [Sean Griffin](https://twitter.com/sgrif), Rails Committer [#11](https://contributors.rubyonrails.org), for a sense check of this approach.
