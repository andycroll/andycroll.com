---
title: "Using Deep Duplication to Avoid Surprises"
description: "Using deep_dup for comprehensive object copying"
layout: article
category: ruby
date: 2025-02-19 01:00
image:
  base: "2024/using-deep_dup-to-avoid-surprises"
  alt: "Repeated windows in a office building"
  credit: "Rex Krithiran"
  source: "https://unsplash.com/photos/a-black-and-white-image-of-a-mans-face-DkU8j3N4xak"
---

When working with complex data structures in Rails, you might need to create a copy of an object that includes all of its nested objects. But beware if you’re copying a complex structure.

Rails provides `deep_dup`, offering a powerful way to create deep copies of object structures.

## Instead of…

...using regular duplication methods which do not copy nested structures

```ruby
og_andy = {
  name: "Andy",
  age: 45,
  address: { city: "Brighton", country: "UK" },
  hobbies: ["football", "parenting"]
}

new_andy = og_andy.dup

# see [thankgoodness.game](https://thankgoodness.game)
new_andy[:address][:city] = "Barnsworth"
new_andy[:hobbies] << "slapping"
new_andy[:hobbies] << "jumping"

og_andy[:address][:city]
#=> "Barnsworth"
og_andy[:hobbies]
#=> ["football", "parenting", "slapping", "jumping"]
```

## Use…

...Rails's `deep_dup` method for comprehensive copying:

```ruby
og_andy = {
  name: "Andy",
  age: 45,
  address: { city: "Brighton", country: "UK" },
  hobbies: ["football", "parenting"]
}

new_andy = og_andy.deep_dup

new_andy[:address][:city] = "Barnsworth"
new_andy[:hobbies] << "slapping"
new_andy[:hobbies] << "jumping"

og_andy[:address][:city]
#=> "Brighton"
og_andy[:hobbies]
#=> ["football", "parenting"]
new_andy[:address][:city]
#=> "Barnsworth"
new_andy[:hobbies]
#=> ["football", "parenting", "slapping", "jumping"]
```

## Why?

The `deep_dup` method, provided by Active Support, creates a fully independent copy of the original object, with all nested structures also duplicated; including nested hashes, arrays, and other objects.

This fully-duplicated structure prevents unintended modifications, as operating on the copy means changes don't affect the original, avoiding subtle bugs—like the above—from occurring in your code.

Note that Rails’s implementation correctly handles custom objects that implement their own `#dup` method.

It's particularly valuable in scenarios where data integrity and isolation are crucial, such as in service objects, form or complex `params` processing, or any situation where you need to work with a copy of data without affecting the original.

The Rails source code itself [contains many uses of the `#deep_dup` method](https://github.com/search?q=repo%3Arails%2Frails%20deep_dup&type=code) where complex arguments are passed into methods or objects for processing. You could use it similarly:

```ruby
def mess_with_passed_params(params)
  attributes = params.deep_dup
  # Then modify `attributes` without changing params
end
```

## Why not?

There _are_ performance implications to consider when using `deep_dup` with very large structures. For extremely large, deeply nested structures, `deep_dup` might have a noticeable performance impact.

It also doesn't create new copies of external resources like database connections or file handles, so is of limited use in those scenarios.

Also if your structure contains singleton objects, you might not want to duplicate them. Singleton objects, by design, are meant to be unique - there should only ever be one instance of them in your application. This is a fundamental principle of the Singleton pattern. When you try to duplicate a singleton object, you're essentially working against its intended purpose.
