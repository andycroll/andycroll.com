---
title: "Use compact_blank to remove empty strings from Arrays and Hashes"
description: "This is one of those “Nice Things” in Rails"
layout: article
category: ruby
image:
  base: '2021/compact_blank-remove-empty-strings-from-array-and-hash'
  alt: "Compact Disc"
  credit: "Jan Huber"
  source: "https://unsplash.com/photos/oTCRizM-PUI"

---

Active Support is a library of “useful” things that supports (!) the other parts of Rails. It includes ways to [extend the base Ruby classes](https://guides.rubyonrails.org/active_support_core_extensions.html), such as `Hash`, `String` and `Integer`.

Even the most experienced Rails developer is constantly finding helpful methods in Active Support that are new to them. And useful methods are continually being added in new versions of the library.

We often have to clean up the values of`Hash`es and `Array`s when parsing paramters, or if our code accepts complex input. Ruby provides the `#compact` method to remove `nil` values from an array and (since 2.4) has provided a [the same `#compact` method](https://ruby-doc.org/core-2.4.0/Hash.html#method-i-compact) for Hash.

In addition to `nil` often we’re looking to remove empty strings or other “blank” objects as well.

## Instead of…

…manually looping through the values of a hash to remove `nil`s and empty strings:

```ruby
[1, nil, “3”, “”, []].compact
#=> [1, “3”, “”, []]

[1, nil, “3”, “”, []].reject { |e| e.nil? || e&.empty? }
#=> [1, “3”]

[1, nil, “3”, “”, []].reject(&:blank?)
#=> [1, “3”]

{1 => 2, 2 => nil, “3” => “4”, 4 => “”, 5 => []}.compact
#=> {1 => 2, “3” => “4”, 4 => “”, 5 => []}

{1 => 2, 2 => nil, “3” => “4”, 4 => “”, 5 => []}.reject { |_, v| v.nil? || v&.empty? }
#=> {1 => 2, “3” => “4”}

{1 => 2, 2 => nil, “3” => “4”, 4 => “”, 5 => []}.reject { |_, v| v.blank? }
#=> {1 => 2, “3” => “4”}
```

## Use…

…Active Support’s `#compact_blank` method:

```ruby
[1, nil, “3”, “”, []].compact_blank
#=> [1, “3”]

result = {1 => 2, 2 => nil, “3” => “4”, 4 => “”, 5 => []}.compact_blank
#=> {1 => 2, “3” => “4”}
```

The [#compact_blank](https://api.rubyonrails.org/classes/Enumerable.html#method-i-compact_blank) method was [added in Rails 6.1](https://github.com/rails/rails/blob/v6.1.4/activesupport/CHANGELOG.md#rails-610-december-09-2020).

## Why?

This is a “useful Rails thing” that feels like it’s part of Ruby once you’re used to it. Many of the core extensions in Active Support have that feeling in common. It reads a _lot_ better than the `#reject`-based versions.


## Why not?

Some folks resent the intrusion of the framework into the base concepts of the language.

However, there have definitely been cases where Ruby has adopted an “Active Support-ism”. `Hash#compact` was in Rails long before it was in the base language.