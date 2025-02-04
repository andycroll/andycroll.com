---
title: "Ordinal Numbers in Rails: 1st, 2nd, 3rd, 4th"
description: "1st, 2nd, 3rd, 4th: turning numbers into their 'spoken' equivalents with ActiveSupport"
layout: article
category: ruby
date: 2025-02-05 02:00
image:
  base: "2025/ordinal-numbers-in-rails"
  alt: "Black & white trophy"
  credit: "Giorgio Trovato (edited)"
  source: "https://unsplash.com/photos/yellow-and-white-trophy-_XTY6lD8jgM"
---

When developing Rails applications, you often need to present numbers in a more human-readable format. For instance, you might want to display "1st" and "42nd" instead of just "1" or "42". Rails provides a neat solution for this through Active Support's Core extensions.

## Instead of…

...avoiding ordinals altogether or using basic string interpolation:

```ruby
position = 1
"You finished in position #{position}"
# => "You finished in position 1"
position = 32
"You finished in position #{32}"
# => "You finished in position 1"
```

## Use…

...Rails’s built-in `ordinal` and `ordinalize` methods:

```ruby
position = 1
"You finished in #{position.ordinalize} place"
# => "You finished in 1st place"

position = 1
"You finished in #{position.ordinalize} place"
# => "You finished in 1st place"
position = 11
"You finished in #{position.ordinalize} place"
# => "You finished in 11th place"
position = 22
"You finished in #{position.ordinalize} place"
# => "You finished in 22nd place"
position = 43
"You finished in #{position.ordinalize} place"
# => "You finished in 43rd place"
```

## Why?

Ordinal numbers make your text read more naturally, especially when dealing with rankings, dates, or lists.

While the examples show English ordinals, these methods are internationalization-aware and can be localized (localised!) for other languages.

As always, with Active Support, this is part of the extended Rails toolkit. You don't need to write and maintain your own logic for determining the correct ordinal suffix and ensure consistent handling across your entire application.

The shown `ordinalize` returns the full ordinal number but there is also `ordinal` that returns just the suffix.

If you're using these methods in your views frequently or when combined with markup, you might want to consider moving the logic to a helper or decorator to keep your views tidy.

```ruby
# app/helpers/number_helper.rb
module NumberHelper
  def wrapped_ordinal(number)
    tag.span(sanitize(number.to_s) << tag.span(number.ordinal, class: "ordinal"))
  end
end

# whatever.html.erb
<%= wrapped_ordinal(1) %>
#=> "<span>1<span class=\"ordinal\">st</span></span>"
```

## Why not?

If you're working in a non-Rails Ruby project, you'd need to add the `activesupport` gem to your dependencies, which patches a lot of methods into the core classes.

However, for the vast majority of Rails applications, using `ordinal` and `ordinalize` is the way to go. They're battle-tested, efficient, and save you from reinventing the wheel or settling for less readable output.
