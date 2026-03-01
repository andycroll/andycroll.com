---
title: "Handle Uncountable Words in Rails Inflections"
description: "Use inflect.uncountable to stop Rails pluralising words like staff, metadata, and feedback."
layout: article
category: ruby
date: 2026-03-23 06:00
image:
  base: "2026/handle-uncountable-words-in-rails-inflections"
  alt: "Herd of sheep running on green grass field"
  credit: "Marco Bianchetti"
  source: "https://unsplash.com/photos/herd-of-sheep-running-on-green-grass-field-ZuV4bPalclY"
---

Some English words don't have a separate plural form. "Staff" is staff, "metadata" is metadata, "feedback" is feedback. Rails doesn't always know this—it will happily generate a `staffs` table or a `metadatas` route if you let it.

## Instead of...

...fighting Rails when it pluralises words that shouldn't change:

```ruby
"staff".pluralize    #=> "staffs"
"metadata".pluralize #=> "metadatas"
"feedback".pluralize #=> "feedbacks"
```

## Use...

...`inflect.uncountable` to tell Rails these words stay the same:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.uncountable %w[staff metadata feedback]
end
```

Now:

```ruby
"staff".pluralize    #=> "staff"
"metadata".pluralize #=> "metadata"
"staff".singularize  #=> "staff"
```

## Why?

Table names, route helpers, association names, and autoloading all depend on correct inflection. When Rails gets it wrong, you end up with a `staffs` table or `metadatas_path` route helpers.

Declaring a word as uncountable fixes this everywhere at once. The `Staff` model maps to the `staff` table. `resources :staff` generates the routes you'd expect.

Words worth declaring uncountable: `staff`, `metadata`, `feedback`, `analytics`, `aircraft`, `software`. You only need to add ones you're actually using as model or resource names. You can pass a single string or an array.

Rails already handles some common uncountable words—`equipment`, `information`, `rice`, `money`, `species`, `series`, `fish`, `sheep`, `jeans`, and `police` work out of the box. Check the [default inflections](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/inflections.rb) to see the full list before adding your own.

See the [ActiveSupport::Inflector::Inflections documentation](https://api.rubyonrails.org/classes/ActiveSupport/Inflector/Inflections.html#method-i-uncountable) for details.

## Why not?

Uncountable words make associations slightly less intuitive. `has_many :staff` reads naturally, but `Staff.all` returning multiple records from a `staff` table can briefly confuse developers expecting a `staffs` table.

If the word is domain-specific jargon your team invented, a regular plural might actually be clearer. Reserve `uncountable` for genuinely uncountable English words, not as a shortcut to avoid a table name you don't like.

This only affects pluralisation. For casing issues with acronyms like API or CSV, that's `inflect.acronym`. For words with non-standard plurals like criterion/criteria, that's `inflect.irregular`.
