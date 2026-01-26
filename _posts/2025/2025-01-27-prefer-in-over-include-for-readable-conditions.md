---
title: "Prefer in? Over include? for Readable Conditions"
description: "A more natural way to check if a value is in a collection"
layout: article
category: ruby
date: 2025-01-27 09:00
image:
  base: "2025/prefer-in-over-include-for-readable-conditions"
  alt: "Band performing on stage in front of a crowd"
  credit: "Vishnu R Nair"
  source: "https://unsplash.com/photos/m1WZS5ye404"
---

When checking if a value exists within a collection, Ruby's `include?` method works but Rails provides a more natural alternative through Active Support's [`in?` method](https://api.rubyonrails.org/classes/Object.html#method-i-in-3F).

## Instead of…

…reading your conditions backwards with `include?`:

```ruby
nsync = ["Justin", "JC", "Chris", "Joey", "Lance"]

if nsync.include?(candidate)
  puts "#{candidate} is in the band"
end

# Or inline
if ["Justin", "JC", "Chris", "Joey", "Lance"].include?(member)
  puts "#{member} can join the inevitable reunion tour"
end
```

## Use…

…Rails's `in?` method for more natural reading:

```ruby
nsync = ["Justin", "JC", "Chris", "Joey", "Lance"]

if candidate.in?(nsync)
  puts "#{candidate} is in the band"
end

# Reads naturally even inline
if member.in?(["Justin", "JC", "Chris", "Joey", "Lance"])
  puts "#{member} can join the inevitable reunion tour"
end
```

## Why?

The `in?` method reads like English. "Is Justin in NSYNC?" becomes `"Justin".in?(nsync)`. Compare that to `nsync.include?("Justin")` which reads as "Does NSYNC include Justin?"—grammatically correct but less intuitive.

The `in?` method works with anything that responds to `include?`: arrays, ranges, sets, and strings.

```ruby
"JC".in?("JC Chasez")                            #=> true
5.in?(1..10)                                     #=> true
:harmony.in?(Set[:melody, :harmony, :rhythm])   #=> true
```

It also handles `nil` gracefully, returning `false` rather than raising an error:

```ruby
"Justin".in?(nil)  #=> false
```

## Why not?

If you're not using Rails, you'd need to add `activesupport` as a dependency. For a single method, that's probably overkill.

Some teams prefer sticking with Ruby's standard library to avoid "magic" methods that might confuse developers unfamiliar with Rails conventions. If your collection is already in a well-named variable, `nsync.include?(name)` reads _fine_.

Performance is identical—`in?` simply calls `include?` on the collection—so choose whichever reads better in context. For inline collections or when the subject of your conditional matters more than the collection, `in?` wins.
