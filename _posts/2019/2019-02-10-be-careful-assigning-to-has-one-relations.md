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

When you assign a new instance of an associated model to its `has_one` model the existing instance is removed from the association and _causes a permanent change to be written to the database_. This happens whether the new model is valid or not.

Read about this side effect of the generated `#association=` method [in the Rails documentation](https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one).


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
person.biography = Biography.new("Looks handsome")
=> #<Biography id: 2, person_id: 1, text: "Looks handsome" ...>
person.reload.biography
=> #<Biography id: 2, person_id: 1, text: "Looks handsome" ...>
Biography.count
=> 2
Biography.first
=> #<Biography id: 1, person_id: nil, text: "Looks handsome" ...>
```

The old model still exists but isn’t associated. And yet I didn't call `#save`…


## Use…

…a transaction to make sure the existing object is deleted if the new object is valid.

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
person.replace_biography(text: "Looks handsome")
=> #<Biography id: 2, person_id: 1, text: Looks handsome ...>
Biography.count
=> 1
```

Boom.


## But why?

The first example demonstrates that the assignment (in this case via `#biography=`) to the `has_one` attribute removes the previously associated model and writes to the database.

In Rails prior to 5.2.1 there is a bug that _even if_ the newly assigned model was invalid and would not save the existing record would still be changed.

Normally when making assignments to the attributes of an Active Record model, via a `#whatever=` method, the changes are not persisted to the database until you call `#save`. In this association case, however, the change to the previously assigned model is written _at the point of assignment_.

The method I’ve created in the second solution uses the `!` variants of the `create` and `destroy` methods inside a transaction to raise exceptions and rollback both the removal of the existing model and assignment of the new one if either fails.

This prevents subtle bugs and the unusual behaviour of implicit writing to the database without calling `#save`.


### In Modern Rails (after 5.0)

In Rails 5.0, if you attempt to set the `person_id` attribute to `nil`, as the assignation of the new model will do, an `ActiveRecord::RecordNotSaved` error is raised. This prevents the assignation even if the new record is valid.

When the `#whatever=` method tries to automatically un-assign the currently associated model it becomes invalid, and an `ActiveRecord::RecordNotSaved` error is raised, because `belongs_to` relationships now have a default [implied presence validation](https://guides.rubyonrails.org/5_0_release_notes.html#active-record-notable-changes). The change in Rails’ behaviour happened in [this pull request](https://github.com/rails/rails/pull/18937).

I used the `optional: true` argument in my example to make the `Person` class behave more like pre-5.0 Rails.

The solution I’ve proposed would also work in these more recent versions of Rails, with a required `belongs_to` relationship. It deletes the currently associated model before creating the new one rather than just trying set the foreign key on the existing model to `nil`.


## Why not?

You can manage the `has_one` relationship in multiple other ways that do not wrap the whole task in a `replace_whatever`-style method such as I’ve suggested.

In fact this [bug fix in Rails 5.2.1](https://github.com/rails/rails/pull/32796) ([commit](https://github.com/rails/rails/commit/c87b3346ca6e1d21a6bccb29ccedf0b95fda7abc)) means the `#whatever=` performs a rollback of the changes, just as my solution would.

You could:

  * Avoid calling the `#whatever=` method in your code and use the clearer `#create_whatever!()` instead
  * Allow assignment only when the association is empty
  * Declare your association with `autosave: true/false` to make the behaviour explicit in your code

…but you will need to manage it somehow.

There is a reasonable argument that using `has_one` leads to more edge cases than the more typical `has_many` relationship. One approach would be to engineer the logic of your application to use that relationship, which might make for more predictable behaviour.


### Thanks..

..to [Sean Griffin](https://twitter.com/sgrif), Rails Committer [#11](https://contributors.rubyonrails.org), for a sense check of this approach.
