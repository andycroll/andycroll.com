---
title: "Customize and abbreviate number_to_human"
description: "Shorter text for bigger numbers"
layout: article
category: ruby
image:
  base: "2023/customize-abbreviate-number_to_human"
  alt: "Dominos"
  credit: "Mick Haupt"
  source: "https://unsplash.com/photos/ePHz9WOME0c"

---

One of Rails’s most helpful view helpers is `number_to_human` and it has many options to customise its output. You can read the [detailed documentation of its many flexible options](https://api.rubyonrails.org/classes/ActiveSupport/NumberHelper.html#method-i-number_to_human).

e.g.

```ruby
number_to_human(12_345)        # => "12.3 Thousand"
number_to_human(1_234_567)     # => "1.23 Million"
number_to_human(1_234_567_890) # => "1.23 Billion"
```

At [work](https://coveragebook.com), our app displays small cards with large numbers on them and we want to display social media-style counts.

The desired translation from numbers to formatted output is:

```ruby
1_234         # => "1.2K"
12_345        # => "12.3K"
1_234_567     # => "1.3M"
1_234_567_890 # => "1.2B"
```

## Instead of…

…customising `number_to_human` whenever you use it:

```erb
<%=
number_to_human(
  1_234_567,
  precision: 1,
  significant: false,
  round_mode: :down,
  format: "%n%u",
  units: {thousand: "K", million: "M", billion: "B"}
)
%>
```

## Use…

…customisation in your `config/locales/en.yml`:

```yml
en:
  number:
    human:
      decimal_units:
        format: "%n%u"
        units:
          unit: ""
          thousand: K
          million: M
          billion: B
          trillion: T
          quadrillion: Q
```

...then use:

```ruby
number_to_human(1_234_567)
#=> "1.2M"
```

## Or…

…a specific custom helper built on top:

```ruby
def number_to_human_short(number)
  return number_with_delimiter(number) if number < 10_000
  
  number_to_human(
    number,
    precision: 1,
    significant: false,
    round_mode: :down,
    format: "%n%u",
    units: {
      thousand: "K",
      million: "M",
      billion: "B",
      trillion: "T"
    }
  )
end
```

...then use:

```ruby
number_to_human_short(1_234_567)
#=> "1.2M"
```

_Adapted from a great recommendation from [Matt Swanson](https://twitter.com/_swanson/status/1694357502043869565) (seen in [Chris Oliver’s](https://twitter.com/excid3) RailsWorld Talk)._


## Why?

Rails provides sensible defaults, but in the same way you have your own in-house design language that probably extends to other elements of your application, like language or number formatting.

In our case we only ever display numbers in the shortened format, so we customised our helpers using using the YAML-configuration approach.

If you need more flexibility, or you have multiple number styles, it is better to use a custom helper. In the example above we special case with an early `return` condition to display all numbers under ten thousand in their entirety; `"9,999"` rather than `"9.9K"`.


## Why not?

If you’re happy with the defaults, or only need the customisation in one or two locations, this would be an unnecessary level of indirection.