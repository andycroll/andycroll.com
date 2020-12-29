---
title: 'AMP Project Pages on Ruby on Rails'
description: 'AMP pages can provide a enhanced SEO, and can be delivered easily from Rails.'
layout: article
category: ruby
image:
  base: '2016/amp-project-pages-ruby-on-rails'
  alt: Lightning
  credit: 'Breno Machado'
  source: 'https://unsplash.com/photos/in9-n0JwgZ0'
---

Google’s [AMP Project](https://ampproject.com) is set to become _a thing_.

> The Accelerated Mobile Pages (AMP) Project is an open source initiative that embodies the vision that publishers can create mobile optimized content once and have it load instantly everywhere.

In short it’s a special ‘version’ of HTML with some Google-specified JS that enables features that make pages super-fast to load. Whatever the politics of this ‘initiative’ it may well help with SEO and we can certainly learn from some of the techniques to improve page load speed.

I'm not going to recommend it from a business perspective as it has some [unfortunate side effects](https://www.alexkras.com/google-may-be-stealing-your-mobile-traffic/), but if you _do_ need to build it… here's how.

At the moment there’s [limited support](https://www.ampproject.org/docs/reference/spec.html) for some HTML features, for example the full gamut of `<form>` related elements, but the spec is moving [at speed](https://www.ampproject.org/roadmap/).

## Adding AMP templates to your Rails application

Edit `config/initializers/mime_types.rb` and add the following line.

```ruby
Mime::Type.register_alias 'text/html', :amp
```

Then adjust the `respond` block in your controller action to read:

```ruby
class ThingsController < ApplicationController
  def show
    @thing = Thing.find(params[:id])
    respond_to do |format|
      format.html.amp
      format.html.none
    end
  end
end
```

Then place your AMP template in `views/things/show.amp.erb`.

```erb
<%
@page_title = @thing.name
@canonical_url = thing_path(@thing)
%>

<h1><%= @thing.name %></h1>
<!-- Whatever HTML representation of @thing you prefer -->
```

You'll also want a very simple `views/layouts/application.amp.erb` file.

```erb
<!doctype html>
<html ⚡>
  <head>
    <meta charset="utf-8">
    <title><%= @page_title %></title>
    <link rel="canonical" href="<%= @canonical_url %>" />
    <meta name="viewport" content="width=device-width,minimum-scale=1,initial-scale=1">
    <style amp-boilerplate>body{-webkit-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-moz-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-ms-animation:-amp-start 8s steps(1,end) 0s 1 normal both;animation:-amp-start 8s steps(1,end) 0s 1 normal both}@-webkit-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-moz-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-ms-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-o-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}</style><noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript>
    <script async src="https://cdn.ampproject.org/v0.js"></script>

    <style amp-custom>
      /* inline styles only */
    </style>
  </head>
  <body>
    <div role="main">
      <%= yield %>
    </div>
  </body>
</html>
```

Note that for valid AMP files you'll need a `<link rel="canonical" href="SOMETHING" %>" />` tag.

Finally you'll need to find a way to add the following line to the `<head>` of your regular non-AMP page.

```erb
<link rel="amphtml" href="<%= thing_path(@thing, format: 'amp') %>" />
```

Then you can just ship it, Google'll start indexing your AMP pages in a jiffy.


## Further information

The details for further validity of AMP files can be found in more detail in [their documentation](https://www.ampproject.org/docs/guides/validate.html). Note that AMP _needs_ validation to be indexed by Google. You can’t "get away with it" like you can with vanilla HTML.

For further "what can I do with AMP" questions, refer to [the AMP documentation](https://www.ampproject.org/docs/get_started/create.html).
