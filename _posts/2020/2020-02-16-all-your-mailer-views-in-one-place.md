---
title: "All Your Mailer Views in One Place"
description: "A little separation"
layout: article
category: ruby
image:
  base: '2020/all-your-mailer-views-in-one-place'
  alt: "Envelopes"
  credit:  Joanna Kosinska
  source: "https://unsplash.com/photos/uGcDWKN91Fs"
---

One of the greatest things that Rails provides to developers is a sensible set of defaults for _where stuff goes_ in the file hierarchy. The standard approach to `app/modals`, `app/mailers`, `app/views`, `config` allows us to arrive at a Rails project and quickly understand where existing code is and where to place our new code.

I’m therefore loathe to deviate much from the defaults, but I make one exception. For email view templates.


## Instead of...

...storing your mailer templates in their default location.

e.g. for `UserMailer`, the mailer is in `app/mailers/user_mailer.rb` and the view templates are in `app/views/user_mailer`.


## Use

...a folder/subdirectory within `app/views` or a new “top-level” directory within `app`.

```ruby
class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"
end
```

...or preferably...

```ruby
class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/mailer_views"
end
```

Then move the files from `app/views/user_mailer` to `app/views/mailers/user_mailer` or `app/mailer_views/user_mailer`.


## Why?

Mailers and Controllers, in Rails, share similar kinds of functionality: reading variables from passed parameters, loading data and rendering output. The Rails codebase reflects this as they both inherit parts of their behaviour from `AbstractController` ([documentation](https://api.rubyonrails.org/classes/AbstractController/Base.html)).

The separation of the mailer views, even if only to a subdirectory within `app/views`, feels more in line with the separation of the mailers (`app/mailers`) from controllers (`app/controllers`).

I find it much easier to find the email templates when I make this small change.


## Why not?

The default is fine, and this is a [pernickety](https://www.collinsdictionary.com/dictionary/english/pernickety) organisational opinion.

It isn’t the default. It could be said you’re making it harder to understand for newcomers to the project. Plus modern IDEs allow fuzzy file lookup so the location of files isn’t that important.