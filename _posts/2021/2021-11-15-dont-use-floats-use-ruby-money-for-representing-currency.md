---
title: "Don't Use Floats and Use the Ruby Money Gem to Represent Currencies"
description: "It's surprising how often you still see this in the wild"
layout: article
category: ruby
image:
  base: "2021/dont-use-floats-use-ruby-money-for-representing-currency"
  alt: "Coins"
  credit: "Dan Dennis"
  source: "https://unsplash.com/photos/pZ56pVKd_6c"

---

We often have to manage monetary values in our applications. And there’s a terrific open source solution in the Ruby community that is _much_ better than rolling your own.


## Instead of…

…using `Float`s or `BigDecimal`s to represent money:

```ruby
# In your migration
add_column :products, :price, :decimal

class Product < ApplicationModel
  def price_to_s
    "$ #{price.round(2).to_s("F")} USD"
  end
end

product.price = 5
#=> 0.5e1
product.price_to_s
#=> "$ 5.0 USD"
```

## Use…

…the Ruby [`money`](https://github.com/RubyMoney/money) gem, or in Rails, the [`money-rails`](https://github.com/RubyMoney/money-rails) gem:

```ruby
# In your migration
add_monetize :products, :price

class Product < ApplicationModel
  monetize :price_cents
end

product.price = Money.from_amount(5, "USD")
#=> #<Money fractional:500 currency:USD>
product.price.format
#=> "$5.00"
```


## Why?

Firstly, _never_ use a non-floating point implementation to represent your your currency values. Floats can introduce rounding errors due to their [underlying representaion inside a computer](http://download.oracle.com/docs/cd/E19957-01/806-3568/ncg_goldberg.html). Just _do not_ do this.

Decimals solve that issue to an extent as they behave in a more intuitive (and money-like) manner.

The `money` gem provides additional benefits as well as enforcing the well-worn recommendations for underlying data structures. It provides a simple, yet sophisticated, battle-tested, “value object” pattern—like all the best gems—for monetary amounts and currencies.

It has a sophisticated implementation of `#format` that works with the standard Ruby internationalisation (i18n) backend to properly (and flexibly) display monetary amounts as strings.

You can also easily convert currencies using the built-in [currency exchange](https://github.com/RubyMoney/money#currency-exchange) functionality, for which you can provide your own rates or link to a number of regularly updated currency rate services.


## Why not?

You might want to code your own your 'money' representation if your application is operating in a more detailed financial modelling world. If you are calculating fractional monetary amounts, the `money` gem may not have the levels of sophistication you require.
