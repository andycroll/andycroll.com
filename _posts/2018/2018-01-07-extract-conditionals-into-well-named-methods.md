---
title: 'Extract conditionals into well-named methods'
description: 'An extraction to a private method often adds clarity'
layout: article
category: ruby
image:
  base: '2018/extract-conditionals-into-well-named-methods'
  alt: 'Jigsaw pieces'
  source: 'https://unsplash.com/photos/3y1zF4hIPCg'
  credit: 'Hans-Peter Gauster'
---

One of the simplest (and most effective) ways to refactor is to [extract a method](https://refactoring.com/catalog/extractMethod.html). The naming of an extracted method, can be especially good for communicating about thinking behind the code.

## Instead of…

...using slightly complex statements in your conditionals.

```ruby
class BrightonCoffeeShop
  def initialize(name)
    @name = name
  end

  def good?
    if @name == 'Starbucks' || @name == 'Costa' ||
       @name == 'Barry’s Caff'
      false
    elsif @name == 'Coffee@33' || @name == 'Small Batch'
      true
    else
      false
    end
  end
end
```

This implementation explicitly returns `false` if the `name` is unknown. This is the only way to guarantee a decent coffee shop experience.


## Use…

...the extract method refactoring to name the concept and move it to a `private` method.

```ruby
class BrightonCoffeeShop
  def initialize(name)
    @name = name
  end

  def good?
    clean? && local? && excellent_coffee?
  end

  private

  def clean?
    !filthy?
  end

  def excellent_coffee?
    ['Coffee@33', 'Small Batch'].include?(@name)
  end

  def filthy?
    @name == 'Barry’s Caff'
  end

  def local?
    !national_chain?
  end

  def national_chain?
    ['Starbucks', 'Costa'].include?(@name)
  end
end
```

We've also refactored to use `Array#include?` for the lists of names.


## But why?

Here, by extracting and naming methods, we have better described what exactly makes a good coffee shop. The private methods act as clear documentation for the class. Before all we really had was a list of 'good' and 'bad' names. You can tell what makes a good coffee shop without even referring to the content of the private methods.

A naive refactoring of this class might have just stuffed all the good and bad names in `GOOD` and `BAD` arrays and checked the `name` against them. In that case we would have lost the reasoning behind _why_ the places were good or bad. And the _why_ is the important part.

In this case I've even named the negative concepts like `#clean?` and `#local?` to avoid using the negative versions of the private methods in the public `#good?` method. This may be overkill in some cases, but adds useful context here as the logic of the conditional is quite specific as to what makes a decent coffee shop.

Before I attempted to refactor I'd want good test coverage of the initial implementation. This will help prevent accidental changes in functionality during the code changes.


## Why not?

In a simpler case I might leave the statement in place, but for this example it is a nice documentation technique as well as clarifying the logic in the conditional.

In a more complex case, where a coffee shop had much more functionality, you could have further refactoring of the different coffee shops to their own subclasses.
