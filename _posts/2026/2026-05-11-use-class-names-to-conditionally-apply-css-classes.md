---
title: "Use class_names to Conditionally Apply CSS Classes"
description: "Stop interpolating CSS classes with ternaries in your ERB templates."
layout: article
category: ruby
date: 2026-05-11 09:00
image:
  base: "2026/class-names-conditionally-apply-css-classes"
  alt: "A purple and white object on a purple background"
  credit: "Joshua Reddekopp"
  source: "https://unsplash.com/photos/a-purple-and-white-object-on-a-purple-background-YQnTaPvCLGo"
---

When you're building views in Rails, you often need to apply CSS classes conditionally. Maybe a nav link should look different when it's the current page, or a form field needs error styling. Since Rails 6.1, the [`class_names`](https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-class_names) helper does this cleanly.

## Instead of...

...interpolating conditional classes with ternaries or post-statement conditionals:

```erb
<div class="p-4 rounded <%= @error ? 'bg-red-50 border-red-500' : '' %> <%= 'opacity-50 cursor-not-allowed' if @disabled %>">
  <%= @message %>
</div>
```

You end up with extra whitespace in the rendered HTML, ERB tags jammed inside an HTML tag (which I'm not a fan of visually), and it's hard to scan which classes are always present and which are conditional.

## Use...

...the `class_names` helper:

```erb
<%= tag.div class: class_names(
  "p-4 rounded",
  "bg-red-50 border-red-500": @error,
  "opacity-50 cursor-not-allowed": @disabled
) do %>
  <%= @message %>
<% end %>
```

`String` arguments (like `"p-4 rounded"`) are always applied. The trailing `Hash` (the keyword-style arguments) includes any key whose value is truthy and silently drops the rest.

An active nav link:

```erb
<%= link_to "Home", root_path,
  class: class_names("nav-link px-3 py-2",
    "text-blue-700 font-semibold": current_page?(root_path)) %>
```

A form field with errors:

```erb
<%= f.text_field :email,
  class: class_names("field",
    "field--error": @user.errors[:email].any?) %>
```

A flash message:

```erb
<% flash.each do |type, message| %>
  <%= tag.p message, class: class_names("flash",
    notice: type == "notice",
    alert: type == "alert") %>
<% end %>
```

An active tab:

```erb
<%= link_to "Overview", project_path(@project),
  class: class_names("tab", "tab--active": current_page?(project_path(@project))) %>
```

Or wrap a repeated pattern in a helper:

```ruby
def class_names_for_project(project)
  class_names("status-badge",
    "status-badge--primary": project.active?,
    "status-badge--muted": project.archived?)
end
```

```erb
<%= tag.span @project.status, class: class_names_for_project(@project) %>
```

## Why?

`class_names` returns an HTML-safe string, so you don't need to worry about escaping. It also splits whitespace-separated tokens and deduplicates them, so `class_names("p-4", "p-4 rounded")` collapses to `"p-4 rounded"` rather than repeating `p-4`.

It's available in any view or helper in Rails, since it's defined in `ActionView::Helpers::TagHelper`. You might also see it referred to as `token_list`, which is the original method name.

## Why not?

If you've only got a single conditional class, plain ERB is readable enough:

```erb
<div class="p-4 <%= 'font-bold' if @important %>">
```

`class_names` does avoid the awkward whitespace issue when the condition is false:

```erb
<%= tag.div class: class_names("p-4", "font-bold": @important) do %>
```
