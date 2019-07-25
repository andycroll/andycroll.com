---
title: "Consider Value Objects"
description: "Making text readable on"
layout: article
category: ruby
image:
  base: '2019/consider-value-objects'
  alt: 'Cubes'
  credit: Christian Fregnan
  source: "https://unsplash.com/photos/TAVKURx-xLw"

---

In your applications, you’ll often find yourself creating a range of view helpers around the same concept, constructing complex calculation methods, or passing a value (or several) around multiple methods.

When this happens a simple object, smaller than an Active Record model, is trying to reveal itself.

In these cases, consider refactoring the functionality into a “Value Object”, as [described by Martin Fowler](https://martinfowler.com/eaaCatalog/valueObject.html):

> A small simple object, like money or a date range, whose equality isn’t based on identity.


## Instead of...

...just using a helper:

```ruby
def css_color(r, g, b)
  "##{r.to_s(16)}#{g.to_s(16)}#{b.to_s(16)}"
end
```

## Use...

...an extracted “Value Object” to truly capture the concept your application is using.

```ruby
class RGBColor
  def initialize(red, green, blue)
    @red = [[0, red].max], 255].min
    @green = [[0, green].max], 255].min
    @blue = [[0, blue].max], 255].min      
  end

  def to_hex
    [@red, @green, @blue].each_with_object("") do |part, to_hex|
      to_hex << part.to_s(16)
    end
  end
end
```

### And in the helper

```ruby
def css_color(r, g, b)
  "##{RGBColor.new(r, g, b).to_hex}"
end
```


## Why?

Just because a concept in our app isn't saved to the database doesn't mean it shouldn’t be an object in our app.

Refactoring into a value object has several benefits since you isolate the code for this concept. You might hear this referred to as ‘separation of concerns’. You can also test the behaviour of your concept in isolation, leading to more comprehensive and efficient tests.

This improved organisation of your code will clarify your understanding. The code/concept is also easier to reuse and you gain a clear place for extending the functionality of the object.


## Why not?

It might be too soon. Finding the correct time to extract a concept into a value object can be difficult. Too early leads to unnecessary complication and potentially increased confusion; too late and you’re already coding in a mess!

For implementation you could use a `Struct` or even `OpenStruct` rather than the class definition approach shown in the example, but these are mutable objects (you can change their properties) which can add complication, rather than simplify your code.
