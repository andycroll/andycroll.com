---
title: "Find definitions of Rails methods using source_location and bundle open"
description: "Show me where the magic comes from."
layout: article
category: ruby
image:
  base: "2023/find-definitions-of-rails-methods-using-source_location"
  alt: "Landsat maps in black and white"
  credit: "USGS"
  source: "https://unsplash.com/photos/white-and-black-abstract-painting-PuLsDCBbyBM"

---  

Given it's a dynamic language, it's important that Ruby comes with several excellent debugging and introspection features out of the box.

Finding the place a method or block of code is defined and reading its source code is essential for effective debugging and code comprehension. In Ruby, `source_location`, provides a powerful tool for retrieving the file and line number where a particular method or block is defined.


## Explore Rails using…

...the `#source_location` method.

```ruby
"Cars".method(:singularize).source_location
#=> ["/.../activesupport-7.0.8/lib/active_support/core_ext/string/inflections.rb", 60]
```

Then open from the command line:

```shell
bundle open activesupport
```

Which opens the named gem in your editor of choice for you to explore.


## Why?

Use of `source_location` is invaluable when you're new to a application, re-exploring unfamiliar code or  trying to understand which gem is providing functionality you're using.

Reading source code is a great way to learn. Reading battle-tested code like Rails, or other gems, even more so.

Thanks to authors of the framework it even works for some of the meta-programmed "generated methods" in Rails. Methods on Active Record [associations that are generated](https://github.com/rails/rails/blob/main/activerecord/lib/active_record/associations/builder/association.rb#L103) using `class_eval` pass special syntax to enable the `source_location` lookup to still work (or you'd just see `(eval)` as the first result.

```ruby
class Car < ApplicationRecord
  has_many :seats

  # ...
end

Car.first.method(:seats).source_location
#=> [".../activerecord-7.0.8/lib/active_record/associations/builder/association.rb", 103]
```

Then open from the command line:

```shell
bundle open activerecord
```

## Why not?

If you experiment you might find that this doesn't work.

```ruby
"Cars".method(:upcase).source_location
#=> nil
```

Methods included as part of "core" Ruby are often implemented in C, and their definitions are not directly accessible from Ruby code. Therefore, calling `source_location` on a core method will typically return `nil`.

The `source_location` method only works for methods defined in Ruby or in Ruby gems where the source code is available. You might also have trouble if the method in question is defined in a C extension, or even when if you do get to the source code, it'll just be a call out to C code!

Also while `source_location` can be invaluable during development and debugging, it's not generally suitable for regular use in production code. 