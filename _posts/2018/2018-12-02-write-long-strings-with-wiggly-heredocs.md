---
title: Write long strings with wiggly HEREDOCs
description: "<<~HEREDOC"
layout: article
category: ruby
image:
  base: '2018/write-long-strings-with-wiggly-heredocs'
  alt: 'Ball of string'
  source: 'https://unsplash.com/photos/8VO-UxlJ-Lw'
  credit: 'Steve Johnson'
last_modified_at: 2020-12-29
---

There’s multiple ways to generate `String` literals in Ruby. If you are creating long, or multi-line, strings, the `HEREDOC` (or 'Here document') is your friend.

Details of the many ways to create String literals can be found in [Ruby’s documentation for Strings](https://ruby-doc.org/core-2.5.3/doc/syntax/literals_rdoc.html#label-Strings).

## Instead of…

...running strings over multiple lines and including newline characters:

```ruby
hamilton = "I am not throwing away my shot!\n" \
           "I am not throwing away my shot!\n" \
           "Hey yo, I’m just like my country\n" \
           "I’m young, scrappy and hungry\n" \
           "And I’m not throwing away my shot!"
```

```ruby
burr = "Geniuses, lower your voices"
burr += "You keep out of trouble and you double your choices\n"
burr += "I’m with you, but the situation is fraught\n"
burr += "You’ve got to be carefully taught:\n"
burr += "If you talk, you’re gonna get shot!\n"
```


## Use…

... a `HEREDOC`.

```ruby
angelica = <<ANGELICA
I’m a girl in a world in which
My only job is to marry rich
My father has no sons so I’m the one
Who has to social climb for one
ANGELICA
```


... or even better a ‘wiggly’ `HEREDOC` (since Ruby 2.3).

```ruby
angelica = <<~ANGELICA
  So I’m the oldest and the wittiest and the gossip in
  New York #{city} is insidious
  And Alexander is penniless
  Ha! That doesn’t mean I want him any less
ANGELICA
```


## But why?

For multi-line strings, the `HEREDOC` is absolutely the right choice. You get the flexibility to edit your text without having to worry about quotes (either single or double) on every line.

You can interpolate variables into your strings just like you can with quoted syntax.

With the “wiggly” variant of the `HEREDOC`, if there is any spacing between the beginning of the first line and the first word in the first line, that amount spacing of spacing is removed from every line. The following two statements produce the same output:

```ruby
throwing_away = <<THROW
I’m not throwing away
My shot
THROW
#=> "I’m not throwing away\nMy shot"

throwing_away_2 = <<~THROW
  I’m not throwing away
  My shot
THROW
#=> "I’m not throwing away\nMy shot"
```


### Why not?

If you’re using multi-line strings for any reason, there’s no reason you wouldn’t use the `HEREDOC`. Stick with the wiggly.
