---
title: "Use blank? and present? in Rails"
description: "Using blank? and present? for cleaner, more idiomatic code"
layout: article
category: ruby
date: 2024-11-11 08:00
image:
  base: "2024/use-blank-and-present-in-rails"
  alt: "Blnak printer paper"
  credit: "Kate Trysh"
  source: "https://unsplash.com/photos/white-printer-paper-WX5jK0BT5JQ"
---

When working with Rails, you often need to check if a value contains meaningful data or if it is effectively empty. Rails, for this very purpose, provides, via Active Support, two very useful methods that are mixed into all objects: `blank?` and `present?`.

## Instead of…

...using a combination of `nil?`, `empty?`, and other checks:

```ruby
def process_data(input)
  if input.nil? || input.empty? || input.strip == ""
    puts "No valid input provided"
  else
    puts "Processing: #{input}"
  end
end
```

## Use…

...Rails’s `blank?` and `present?` methods:

```ruby
def process_data(input)
  if input.blank?
    puts "No valid input provided"
  else
    puts "Processing: #{input}"
  end
end

# Or, using present?
def process_data(input)
  if input.present?
    puts "Processing: #{input}"
  else
    puts "No valid input provided"
  end
end
```

## Why?

The `blank?` and `present?` methods consolidate multiple checks into a single, readable method call. Your code becomes more expressive and easier to understand at a glance.

These methods are part of Active Support Core Extensions and thus work consistently across different types of objects (strings, arrays, hashes, etc.). They correctly handle cases such as strings containing only whitespace, which a simple `empty?` check would incorrectly classify as having meaningful content.

Here's a quick rundown of how `blank?` behaves with different inputs:

```ruby
nil.blank?      # => true
false.blank?    # => true
true.blank?     # => false
"".blank?       # => true
"   ".blank?    # => true
"hello".blank?  # => false
[].blank?       # => true
{}.blank?       # => true
1.blank?        # => false
0.blank?        # => false
```

And `present?` is simply the opposite of `blank?`:

```ruby
value.present? # is equivalent to !value.blank?
```

## Why not?

While `blank?` and `present?` are incredibly useful, there are a few situations where you might choose not to use them.

If you're working in a pure Ruby environment, you'd need to add the `active_support` gem to use these methods. Or if you need to distinguish between different types of "empty" (e.g., `nil` vs. empty string), more specific checks might be necessary.

For extremely performance-critical code, using `blank?` might be slightly slower than a direct `nil?` or `empty?` check, as it can use multiple methods internally. But your mileage may vary and you should benchmark to determine if this is a concern for your specific usage.

## Additional reading

For the vast majority of Rails applications, using `blank?` and `present?` leads to cleaner, more idiomatic, and more maintainable code. For a further enhancement, check out [`presence`](/ruby/use-the-presence-method), which can also make your code more expressive.
