---
title: "Use beginning and end of string in regular expressions"
description: 'Copying and pasting can lead you astray'
layout: article
category: ruby
image:
  base: '2018/beginning-and-end-of-string-in-regex'
  alt: 'Tile Pattern'
  source: 'https://unsplash.com/photos/jR4Zf-riEjI'
  credit: 'Andrew Ridley'
---

We often validate user input using regular expressions.

There are lots of regular expressions on the Internet. Every now and then we might 'borrow' one to save ourselves the life-sapping pain of creating one anew.

However, we should beware.


## Instead of…

…using `^` and `$` to enclose the regular expression.

```ruby
# A regular expression matching a
# string of lowercase letters
/^[a-z]+$/
```


## Use…

…`\A` and `\Z`.

```ruby
# A regular expression matching a
# string of lowercase letters
/\A[a-z]+\Z/
```


## But why?

Being specific in this case will reduce potential security holes in your code.

The characters `^` and `$` match the beginning and end of a _line_, not the beginning and end of an entire string.

If your validations are not precise you could allow potentially dangerous user input to be permitted.

e.g.

```ruby
> "word\n<script>run_naughty_script();</script>".match?(/^[a-z]+$/)
=> true

> "word\n<script>run_naughty_script();</script>".match?(/\A[a-z]+\z/)
=> false
```

The string above, with its potentially harmful JavaScript, gets through the looser validation of `^` and `$`. You certainly don’t want to let that sort of thing through your validations.


## Why not?

This is a case where being specific is important. Just do it.
