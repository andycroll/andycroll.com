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

One of the simplest (and most effective) ways to refactor is to [extract a method](https://refactoring.com/catalog/extractMethod.html). The naming of an extracted method is a great tool for communicating the thinking behind the code.

## Instead of…

…using slightly complex statements in your conditionals.

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

This implementation explicitly returns `false` if the `name` is unknown. The only way to guarantee a decent coffee shop experience is to rule out places you’ve never heard of. Right? :-)


## Use…

…the Extract Method refactoring to move the logic into a `private` method, giving that method a name that clearly explains the concept of the code.

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


## But why?

By extracting a method you, by definition, name it. Our `#good?` method states the specific criteria for a good coffee shop. The new private methods act as documentation for the class.

Before, all we really had was a list of 'good' and 'bad' coffee shops. We had no knowledge of how those lists were developed.

A naive refactoring of this class might have just stuffed all the good and bad names in arrays named `GOOD` and `BAD` and checked the coffee shop `name` against them. We would have lost the reasoning behind _why_ the places were good or bad. And the _why_ is the most important part.

In this case I've extracted the negative concepts of `#filthy?` and `#national_chain?` as well as the positive concepts like `#clean?` and `#local?`. This avoids using the negative versions of the private methods in the `#good?` method, making that method more readable. You could consider this overkill in some cases, but here it adds useful context as this class is heavily geared towards the positive qualities of a decent coffee shop.

Before any refactoring it is important to ensure good test coverage of the initial implementation to prevent accidental changes in functionality.


## Why not?

In a simpler example, I might not even bother with this kind of refactoring, but here it serves as a nice documentation technique and clarifies the logic in the conditional.

In a more complex case, where a coffee shop has much more functionality (more than just being good or not) you might further refactor each of the different coffee shops into subclasses.
