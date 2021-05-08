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

In our applications, we often use environment variables to configure the application itself or connections to third party services. These values are then accessed through the special [`ENV` hash provided by Ruby](https://ruby-doc.org/core-3.0.1/ENV.html).


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

The major benefit here is the encapsulation of environmental settings, tokens & configuration into one place. Rather than using `ENV` variables throught your code base, now you have a single place to translate environment variabes into your app.

I also find this style to be more attractive in usage than querying the `ENV` hash.


### Further improvements?

You can use `ENV.fetch("VARIABLE_NAME")` within the `Settings` object to raise errors if an `ENV` value is required by your application and is not present.

As your environment becomes more complex you might use multiple (very similar) objects, perhaps to separate out `Settings` and `Tokens`.


## Why not?

This is a style and organisation improvement that'll have the most impact on slightly larger projects.

There is the encrypted credentials functionality built into versions of Rails after 5.2. The documentation on that Rails feature is [brief at best](https://guides.rubyonrails.org/security.html#environmental-security)and I've never got on with it. If you mainly deploy to Heroku you might prefer to keep configuration in the environment as argued for in the [twelve-factor manifesto](https://12factor.net).

There are also gems that provide similar wrappers around your `ENV`ironment, but I've never found one that had as clear and effective API as building your own configuration object.
