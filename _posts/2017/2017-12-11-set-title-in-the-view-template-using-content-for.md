---
title: 'Set your page title in the view template using content_for'
description: 'Cut out all that instance variable nonsense.'
layout: article
category: ruby
image:
  base: '2017/set-title-in-the-view-template-using-content-for'
  alt: 'Books'
  credit: 'Annie Spratt'
  source: 'https://unsplash.com/photos/-9vMBjrU-RA'
---

Rails has `content_for` as it’s primary way to store content in one place for use in other views, layouts or helpers. See `content_for` in the Rails documentation at [in the ActionView helpers](http://api.rubyonrails.org/v5.1.3/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for).

## Instead of…

...using an instance variable in the controller.

### `things_controller.rb`

```ruby
def show
  @page_title = 'Page Title'
  # other controller stuff
end
```

### And `views/layouts/application.html.erb`

In the `<head>`.

```erb
<title><%= @page_title || 'Default' %></title>
```


## Use…

...`content_for` and `yield`.

### `things/show.html.erb`

I like to put the title at the top of the individual view file.

```erb
<% content_for(:html_title) { 'Title' } %>
```

### And `views/layouts/application.html.erb`

In the `<head>`.

```erb
<title><%= content_for?(:html_title) ? yield(:page_title) : "Default" %></title>
```


## But why?

Using `content_for` in this way keeps information about how to render the page inside the relevant view template. It also avoids cluttering the controller with non-business logic.

You also avoid creating yet another 'magic' instance variable that gets automatically revealed to the view by Rails.

Another heuristic for using this technique is that when rendering JSON and/or AJAX from the same restful action, those versions don't need a page title, indicating it belongs in the HTML view template.

You _can_ also use the `content_for` in multiple places in your views and the values are concatenated when they are `yield`ed in the layout. Not so useful in this case... but good to know.


## Why not?

You're fighting the framework if you use the instance variable approach, even though it _does_ work.
