---
title: Twitter Bootstrap & Kaminari Pagination
layout: post
category:
  - ruby
redirect_from:
  - /2011/12/07/twitter-bootstrap-and-kaminari-pagination/
---

In the process of putting together the first of many internal tools for ImpulseFlyer I've utilised the marvelousness of Twitter Bootstrap.

The beauty of bootstrap is in its ability to remove decision-making about how front-end HTML should be coded. For internal projects this is great, I can concentrate on functionality and straightforward layout and have everything else 'kinda look ok'. I wouldn't use it 'pure' in an outside facing project, but for internal projects/prototyping it's perfect.

In the course of building out administrative tools I also had cause to use [kaminari](https://github.com/amatsuda/kaminari) for pagination. So I [forked the kaminari themes](https://github.com/andycroll/kaminari_themes/) to provide a useful set of templates if you're using bootstrap.

I note from the issues queue I'm not the first to provide this to be pulled back into the main themes repository, but I think I'm the 'completest'.

You can simply copy the HTML (or HAML) templates into 'app/views/kaminari' if you want to use them.
