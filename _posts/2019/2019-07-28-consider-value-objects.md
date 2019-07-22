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

Often we use simple concepts in our app, that don't start out as objects.

You'll often find yourself creating multiple view helpers or passing a value (or several) around several methods, or within a model.

This loose concept can be refactored into a “Value Object”.


## Instead of...

...just using a helper.

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
  #
  # def self.from_hex(hex)
  #   new(hex[0, 2], hex[2, 2], hex[4, 2])
  # end

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

Martin Fowler [defines a Value Object](https://martinfowler.com/eaaCatalog/valueObject.html) as:

> A small simple object, like money or a date range, whose equality isn’t based on identity.

Refactoring into an object has several benefits as you isolate and separate the code for this concept. You might hear this referred to as ‘separation of concerns’.

Your can test the behaviour of your concept in isolation. Thus more comprehensively and efficiently.

The improved understanding and organisation of your code improves your understanding and you gain the benefits of reuse as well as a place for extensions to the concept you've created.


## Why not?

It might be too complex, too soon.

Finding the correct time to extract a concept can be difficult. Too early leads to over-complication and confusion, too late and you’re already coding in a mess!

For implementation you could use a `Struct` or even `OpenStruct` rather than the class definition approach shown in the example, but they are mutable objects (you can change their values) which can add complication rather than help to simplify.
