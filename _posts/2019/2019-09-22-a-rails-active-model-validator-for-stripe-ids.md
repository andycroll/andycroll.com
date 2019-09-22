---
title: "A Active Model validator for Stripe Ids"
description: "A decent example"
layout: article
category: ruby
image:
  base: '2019/a-rails-active-model-validator-for-stripe-ids'
  alt: 'Zebra stripes'
  credit: David Clarke
  source: "https://unsplash.com/photos/sN6d60TySV0"

---

In [my article on using validators](/ruby/use-a-custom-validator), the example was pretty simple.

In this example, we discuss the real production use of a more complex validator extracted from the billing code in [AnswerThePublic](https://answerthepublic.com). We use [Stripe](https://stripe.com) exclusively for billing in our applications.

Every object on Stripe—a transaction, an invoice, a customer—has a unique and similarly-patterned identifier. We often need to store these `id`s locally in our application to interact with Stripe so that they can interact with Stripe and we can collect payments from customers.

We want to make sure we don’t store incorrectly-formatted Stripe `id`s in our application’s database or we might introduce errors in our eventual API calls.


## Instead of...

...using a regex in `validates` when setting a format for the `stripe_id`:

```ruby
class Subscription < ActiveRecord
  validates :stripe_id, format: { with: /\Asub\_[A-Za-z0-9]{8,}\z/ }
end
```


## Use...

...a validator class to ensure the format of a Stripe `id`...

```ruby
# app/validators/stripe_validator.rb
class StripeValidator < ActiveModel::EachValidator
  VALID_PREFIXES = %w[ch cus in plan sub txr].freeze

  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || 'is not a valid Stripe ID') unless regex(options[:prefix]).match?(value)
  end

  def check_validity!
    raise ArgumentError, 'Requires :prefix' unless options.include?(:prefix)
    raise ArgumentError, 'Invalid :prefix supplied' unless VALID_PREFIXES.include?(options[:prefix].to_s)
  end

  private

  def regex(value)
    /\A#{value}\_[A-Za-z0-9]{8,}\z/
  end
end
```

...then use it in models like so:

```ruby
class Subscription < ActiveRecord
  validates :stripe_id, stripe: { prefix: :sub }
end

class Invoice < ActiveRecord
  validates :stripe_id, stripe: { prefix: :in }
end
```

## Why?

I wanted to provide a useful, concrete example where extracting a validator (in this case for a popular and well-used service) can help keep your code clear and concise.

This validator can be reused across multiple models in our own domain that have records on Stripe accessible via their API, reducing potential errors, and ensuring our application data matches up to our data on Stripe.

The extra structure improves the clarity of your code when you, or another developer, come back to it. There’s now one place in our app to validate the format of all our Stripe identifiers.


## Why not?

You could use a specific regex for each model’s validation, but you’d lose the extra expressiveness in the model from naming and extracting the validator.

“This field must be a stripe id with the prefix ‘in’” is clearer to read and understand than “This field must match a confusing regular expression”.
