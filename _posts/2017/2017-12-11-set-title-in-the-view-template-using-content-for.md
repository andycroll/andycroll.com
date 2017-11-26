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

Rails uses `content_for` as its primary way to store content in one place for use in other views, layouts or helpers. Find out more about `content_for` in the Rails documentation in the [ActionView helpers](http://api.rubyonrails.org/v5.1.3/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for) section.

## Instead of…

...using an instance variable in the controller...

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

Using `content_for` keeps information about how to render the page inside the relevant view template, it avoids cluttering the controller with non-business logic.

You avoid creating yet another 'magic' instance variable that gets automatically passed to the view by Rails.

Here's another way you know I'm right about how you should set your page titles. Rendering JSON or AJAX from the same RESTful controller action doesn't require adding a page title. Therefore, it's clear that this information should live with the relevant HTML view template.


## Why not?

You're fighting the framework if you use the instance variable approach, even though it _does_ work.
