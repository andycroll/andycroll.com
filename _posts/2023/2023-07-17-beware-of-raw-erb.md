---
title: "Beware of <%== in your erb files"
description: "The danger of an extra equals"
layout: article
category: ruby
image:
  base: "2023/beware-of-raw-erb"
  alt: "A hand holding a piece of sushi with chopsticks"
  credit: "Luc Bercoth"
  source: "https://unsplash.com/photos/REPQln8St2E"
---

XSS, which stands for Cross-Site Scripting, is a common vulnerability that allows attackers to inject malicious scripts into web pages viewed by other users. These scripts can be used to steal sensitive information, manipulate the page's content, or perform other malicious actions on behalf of the attacker.

One of the benefits of frameworks like Rails is that XSS protection is built-in and automatically applied to user-provided content. Rails uses a combination of context-aware output encoding and automatic escaping to mitigate XSS vulnerabilities.

Rails automatically escapes HTML entities when rendering user input within HTML templates by default, and then uses a special class called `ActiveSupport::SafeBuffer` to handle string concatenation and the final rendering of the user-generated content. `SafeBuffer` is designed to prevent inadvertent double-escaping of the string or bypassing of encoding mechanisms.

But you can, and folks do, go around it.

## Instead of…

…using:

```erb
<%== @some_text_to_render %>
```

## Use…

…Rails’s sanitization methods to ensure content is made safe before it gets to the view:

```ruby
# In the controller
@some_text_to_render = "some text #{params[:user_text]}".sanitize
```

```erb
<%= @some_text_to_render %>
```

## Why?

This is primarily about defending your application against malicious user input. Using the `<%== something %>` ERB tags in a Rails view template is the same as writing `<%= raw(something) %>`, which completely avoids the protections offered by `SafeBuffer`.

If you see `<%==` or `<% raw` in your ERB, consider it a bad smell. You should carefully evaluate the context, the source of the data, and the potential security risks before deciding to bypass HTML escaping. In general, don't.

If you look inside [ActiveSupport::SafeBuffer](https://api.rubyonrails.org/classes/ActiveSupport/SafeBuffer.html), you’ll see methods like `html_safe?`, which are the methods Rails uses to manage the safety of user input that you're displaying in the browser.

As the [docs for `html_safe`](https://api.rubyonrails.org/classes/String.html#method-i-html_safe) say “It should never be called on user input”. You should let Rails do what it is good at.

You might also find [`#safe_join`](https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-safe_join) useful. It behaves like `Array#join` but flattens the array, escapes all the unsafe strings, and returns an HTML safe string. h/t [Dorian Marié](https://dorianmarie.com)

```ruby
# In the controller
@some_text_to_render = ["some text ", params[:user_text]].safe_join
```

## Why not?

There’s a couple of places you regularly see the use of unescaped HTML.

The [`pagy` gem](https://github.com/ddnexus/pagy) recommends using the raw syntax `<%== pagy_nav(@pagy) if @pagy.pages > 1 %>`. This is safe to use because the output of `pagy_nav` is handled by the gem and there's very little risk of XSS as a result.

The are two other cases where using unescaped HTML is okay:

One is for performance. There is a small overhead to managing the sanitization of each string. If you have a large amount or very long strings you _may_ see a performance improvement by avoiding the escaping.

The other is where managing the escaping of complicated strings is tricky, but that is _precisely_ where you need to do the work to properly manage potentially treacherous input yourself, or let the framework take the strain.
