---
title: Don't use instance variables in partials
description: Containment is key
layout: article
category: ruby
image:
  base: '2019/dont-use-instance-variables-in-partials'
  alt: 'Partial eclipse'
  source: "https://unsplash.com/photos/NbgQfUvKFE0"
  credit: "Mark Tegethoff"
---

Rails’ view architecture is a flexible and magical place. Perhaps too much.

Instance variables from controllers, like `@whatever`, are magically available in view templates. Inferred template names. A global namespace of helpers. For some it's too much, but most of us accept the “magic” and muddle through any strangeness.


## Instead of…

…using the global variables from your template inside your partials, pass the values as local variables.

#### `album/show.html.erb`

```erb
...
<% @album.songs.each do |song| %>
  <h2><%= song.name %></h2>
  <%= render "character", collection: song.characters, as: :character %>
<% end %>
...
```

#### `song/_character.html.erb`

```erb
...
<p><%= character.name %></p>
<div class="popup">
  Other Songs: <%= character.features_on_tracks(@album.songs).to_sentence %>
</div>
...
```



## Always…

…pass variables into your partials so they don’t expect any global state.

#### `album/show.html.erb`

```erb
...
<% @album.songs.each do |song| %>
  <h2><%= song.name %></h2>
  <%= render "character", collection: song.characters,
                          as: :character,
                          locals: { songs: @album.songs } %>
<% end %>
...
```

#### `song/_character.html.erb`

```erb
...
<p><%= character.name %></p>
<div class="popup">
  Other Songs: <%= character.features_on_tracks(songs).to_sentence %>
</div>
...
```


## But why?

It’s too easy to presume that certain instance variables, in this case `@album`, are available in the context your partial is called in.

When you first extract the partial, for organisation, it is only used in one place. When you reuse the partial somewhere else in your application the controller action in which it is eventually called must also correctly assign that exact variable.

As your application becomes more complex a view might contain several partials—each expecting their own instance variables—so you’ll need to assign several instance variables in the controller action. The context of these assignments will be a long way from the nested partial in which they’re used.

By not using instance variables your partials also benefit from simpler reuse.

This “early magic, later complexity” is one of the issues that people have with Rails’ HTML rendering environment.


### A little help

You can find lines in view partials which reference an instance variable by using this command from the root of your application in your Terminal.

```shell
grep -rEHn "\@\w+" --include "_*.erb" app/views
```



## Why not?

It might feel easier to leave any instance variables in place and it can also feel redundant to write the additional code needed in order to define the partial’s variables in the call to `render`. However, not making these changes will bite you in the end.

It's certainly _never_ a good idea to create an instance variable to share it between partials.

Note that there are other issues in the example I've used. It looks like the call to `character#features_on_tracks` will probably invoke some sort of database query.
