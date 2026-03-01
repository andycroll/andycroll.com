---
title: "Declare Acronyms in Rails Inflections"
description: "Use inflect.acronym to keep API, SMS, and other acronyms correctly cased in class names and autoloading."
layout: article
category: ruby
date: 2026-03-16 06:00
image:
  base: "2026/declare-acronyms-in-rails-inflections"
  alt: "Colorful wooden letter blocks scattered together"
  credit: "Susan Holt Simpson"
  source: "https://unsplash.com/photos/letter-block-toy-Rd01U0tPmQI"
---

A lot of Rails's naming magic comes from its clever use of inflections. `user.rb` defines the `User` class, backed by the `users` table, managed by `UsersController`, accessible at the `/users/` routes.

Every Rails app generates `config/initializers/inflections.rb` to let you customise this behaviour. Most developers leave it empty. Then one day you namespace a controller under `API` and Rails starts generating `Api::UsersController` instead of `API::UsersController`.

## Instead of...

...accepting the wrong casing in your class names:

```ruby
# app/controllers/api/users_controller.rb
class Api::UsersController < ApplicationController
end
```

## Use...

...`inflect.acronym` to teach Rails the correct casing:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "API"
end
```

Now Rails expects `API::UsersController`. The file path stays lowercase (`app/controllers/api/`), but the class name uses the acronym:

```ruby
# app/controllers/api/users_controller.rb
class API::UsersController < ApplicationController
end
```

## Why?

The `acronym` method tells ActiveSupport's inflector to preserve the casing you specify. It affects `camelize`, `underscore`, `classify`, and `titleize`—which means it also affects autoloading and URL helpers.

```ruby
"api".camelize        #=> "API"
"API".underscore      #=> "api"
"api/users".camelize  #=> "API::Users"
```

Without the acronym declaration, you get `Api` instead:

```ruby
"api".camelize  #=> "Api"
```

Unlike irregular plurals and uncountable words, Rails ships with [no built-in acronyms](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/inflections.rb)—every one you need, you have to declare yourself. Common ones worth adding: `API`, `SMS`, `CSV`, `HTML`, `PDF`. One call per term:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "API"
  inflect.acronym "SMS"
  inflect.acronym "CSV"
end
```

This also works for mixed-case words like `GraphQL` or `GitHub`. `inflect.acronym "GraphQL"` ensures `"graphql".camelize` returns `"GraphQL"` rather than `"Graphql"`.

See the [ActiveSupport::Inflector::Inflections documentation](https://api.rubyonrails.org/classes/ActiveSupport/Inflector/Inflections.html#method-i-acronym) for details.

## Why not?

Since it's an initialiser, you'll need to restart your Rails server after making changes.

Keep the list short. Every entry changes how `camelize`, `titleize`, `humanize`, and `underscore` behave across your entire app. Only add acronyms you're actively using—whether in class names, attribute labels, or view helpers.

This only affects casing, not pluralisation. For words with non-standard plurals like criterion/criteria, that's `inflect.irregular`. For words that don't pluralise at all, that's `inflect.uncountable`.
