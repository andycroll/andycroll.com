---
title: "Wrap your environment variables in a singleton settings object"
description: "It helps keep your configuration in one place"
layout: article
category: ruby
image:
  base: "2021/wrap-your-environment-variables-in-a-singleton-settings-object"
  alt: "A gift wrapped in pink paper"
  source: "https://unsplash.com/photos/rO20Sn1FWo4"
  credit: "Nick Fewings"
---

Often in our applications we use environment variables to configure our application or to configure connections to third party services. These values are accessed through the special [`ENV` hash provided by Ruby](https://ruby-doc.org/core-3.0.1/ENV.html).


## Instead of...

...using environment variables in your code:

### `app/views/layouts/application.html.erb`

```erb
...
<% if ENV["ANALYTICS_TOKEN"] %>
<script>
  window.analytics_token = <%= ENV["ANALYTICS_TOKEN"] %>
  ...blah_js...
</script>
<% end %>
...
```


## Use...

...an object to wrap your configuration:

### `config/initializers/settings.rb`

```ruby
class Settings
  class << self
    def analytics?
      !!analytics_token
    end

    def analytics_token
      ENV["ANALYTICS_TOKEN"]
    end
  end
end
```


### `app/views/layouts/application.html.erb`

```erb
...
<% if Settings.analytics? %>
<script>
  window.analytics_token = <%= Settings.analytics_token %>
  ...blah_js...
</script>
<% end %>
...
```


## Why?

The major benefit here is the encapsulation of environmental settings, tokens & configuration into one place. Rather than using `ENV` variables all over the place, now you have a single place to look.

I also find the object-style to be more attractive in usage than querying the `ENV` hash.


### Further improvements?

You can also use `ENV.fetch("VARIABLE_NAME")` to raise errors if an `ENV` value is required by your application.

As your environment becomes more complex you might use multiple (very similar) objects, perhaps to seperate out `Settings` and `Tokens`.


## Why not?

This is a style and organisation improvement that'll have the most impact on slightly larger projects.

There is the encrypted credentials functionality built into versions of Rails after 5.2. The documentation on that Rails feature is [brief at best](https://guides.rubyonrails.org/security.html#environmental-security)and I've never got on with it.

Also as I mostly deploy to Heroku I prefer to keep configuration in the environment as argued for in the [twelve-factor app](https://12factor.net).

There are also gems that provide similar wrappers around your `ENV`ironment, but I've never found one that had as clear and effective API as building your own configuration object.

