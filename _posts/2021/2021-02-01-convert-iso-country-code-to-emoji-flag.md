---
title: "Convert a two character ISO country code to an emoji flag"
description: "From ISO 3166-1 alpha-2 to lovely emoji flag"
layout: article
category: ruby
image:
  base: '2021/convert-iso-country-code-to-emoji-flag'
  alt: "Emoji flags"
---

We often store references to countries in our applications as a two-letter code inline using the [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) standard. For example, "GB" for the United Kingdom or "US" for the United States.

But the people demand emoji and who are we to deny them?

```ruby
def emoji_flag(country_code)
  cc = country_code.to_s.upcase
  return unless cc =~ /\A[A-Z]{2}\z/

  cc.codepoints.map { |c| (c + 127397).chr(Encoding::UTF_8) }.join
end

> emoji_flag("eu")
#=> "🇪🇺"
```


## How does this work?

The first two lines can be classed as 'defensive code', which makes the method more resilient against different kinds of input.

```ruby
cc = country_code.to_s.upcase
```

...ensures you're working with an upper case string. And...

```ruby
return unless cc =~ /\A[A-Z]{2}\z/
```

...provides an early return of `nil` when the passed string isn't two captial letters.

You could make an argument and say we should return `""` rather than `nil` to ensure the method always returns a string, but although it can be a pain, it's more "ruby-ish" to return `nil`.

### The clever bit, explained

Every country (and some previously existing countries) has a [unique two-character code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Current_codes).

There is a [unique Unicode character for every capital letter](https://en.wikipedia.org/wiki/Enclosed_Alphanumeric_Supplement) and within that there are 26 sequential [regional indicator symbols](https://en.wikipedia.org/wiki/Regional_indicator_symbol). This means `A` has a corresponding `🇦` regional indicator.

An emoji flag is constructed by the text rendering of your operating system using two of these unicode indicator characters. For example, the 🇪🇺  character displayed on your screen is made up from a UTF-8 string containing the `🇪` and `🇺` characters consecutively.

```ruby
"🇪🇺".chars
=> ["🇪", "🇺"]
```

The Unicode table of characters contains both these regional indicators and the standard capital letter characters.

The character `A` is at codepoint 65, its corresponding `🇦` is at codepoint 127,462. There's a consistent difference of 127,397 between each capital and its matching regional indicator. This "magic" number is the key to the translation method.

The main functionality of the code relies on breaking up the two-character string and converting each character into its numerical representation, found in the ASCII/UTF-8 character table via the [`#codepoints` method](https://ruby-doc.org/core-3.0.0/String.html#codepoints-method). Then add 127,397 to each codepoint then convert this new reference back to a UTF-8 encoded character. Finally we `#join` the two regional indicator characters back together into a `String`.

If we were to explore this process step-by-step for France...

```ruby
"FR".codepoints
=> [70, 82]

70 + 127397
=> 127467

127467.chr(Encoding::UTF_8)
=> "🇫"

82 + 127397
=> 1274879

127479.chr(Encoding::UTF_8)
=> "🇷"

["🇫", "🇷"].join
=> "🇫🇷"

"🇫🇷".codepoints # to check
=> [127467, 127479]
```

We rely on the combined UTF-8 text-rendering of ruby and a modern operating system to ensure the flag is displayed instead of the two indicator characters.

This method is pretty forgiving, because of the thoughtful structure of the Unicode character table. If an unused country code is passed it renders the two regional indicators as a fallback.

```ruby
emoji_flag("AA")
=> "🇦🇦"
```
