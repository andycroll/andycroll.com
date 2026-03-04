---
title: "Teach Rails Irregular Plurals with Inflections"
description: "Use inflect.irregular to teach Rails non-standard plurals like criterion/criteria."
layout: article
category: ruby
date: 2026-03-30 06:00
image:
  base: "2026/teach-rails-irregular-plurals-with-inflections"
  alt: "A flock of birds flying in a V formation against a cloudy sky"
  credit: "Mike Cox"
  source: "https://unsplash.com/photos/a-flock-of-birds-flying-in-a-v-formation-6le9aDY_KC0"
---

English has plenty of irregular plurals. Criterion becomes criteria, not criterions. Rails handles many common ones already, but your domain might include words it doesn't know about.

## Instead of...

...accepting Rails' best guess at a plural:

```ruby
"criterion".pluralize  #=> "criterions"
"matrix".pluralize     #=> "matrices"  # this one Rails knows!
```

## Use...

...`inflect.irregular` to teach Rails the correct pair:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "criterion", "criteria"
end
```

Now:

```ruby
"criterion".pluralize  #=> "criteria"
"criteria".singularize #=> "criterion"
```

## Why?

Give `irregular` the singular and plural forms and Rails handles both directions—`pluralize` and `singularize` both work correctly.

A `Criterion` model will look for a `criteria` table. `resources :criteria` will route to `CriteriaController`. Association names, fixtures, and factory names all follow suit.

```ruby
class Criterion < ApplicationRecord
  # table: criteria
end

class Survey < ApplicationRecord
  has_many :criteria  # works as expected
end
```

You can declare as many as you need:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "criterion", "criteria"
  inflect.irregular "goose", "geese"
end
```

Although, unless you're building some kind of flighted animal tracker, you probably won't need that second one.

Rails already knows a handful of irregular plurals: person/people, man/men, child/children, sex/sexes, move/moves, and—crucially—zombie/zombies are built in. Rails's pluralisation rules are regex-based, so the `(m)an → (m)en` pattern also covers woman/women. But that's it—words like tooth/teeth, foot/feet, mouse/mice, and goose/geese are not handled by default. Check the [default inflections](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/inflections.rb) to see what's already covered.

See the [ActiveSupport::Inflector::Inflections documentation](https://api.rubyonrails.org/classes/ActiveSupport/Inflector/Inflections.html#method-i-irregular) for details.

## Why not?

Before adding an irregular inflection, check whether Rails already knows the word. Try it in a console:

```ruby
"person".pluralize  #=> "people"  — already works
"axis".pluralize    #=> "axes"    — already works
```

If it's already correct, adding it to your initialiser is just noise.

If the word never appears as a model or resource name, there's no reason to declare it.

For words that don't change between singular and plural (like "sheep" or "metadata"), that's `inflect.uncountable`. For casing issues with acronyms like API or CSV, that's `inflect.acronym`.
