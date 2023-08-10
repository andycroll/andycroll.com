---
title: "Play in a sandbox in production"
description: "Prevent disasters with a little caution"
layout: article
category: ruby
image:
  base: "2023/play-in-a-sandbox-in-production"
  alt: "Toy truck in the sand"
  credit: "Markus Spiske"
  source: "https://unsplash.com/photos/KU3lOAiP-tQ"

---

As a developer you often have privileged access to the production environment of your application. This is often required to do bug fixes or to run commands for folks in your organisation.

However with great power comes a great ability to shoot yourself in the foot. It’s all to easy to make damaging changes to user data without meaning too.

Thankfully Rails gives us some nice protection, but you have to opt-in to using it.

## Instead of…

…using:

```shell
$ heroku run rails console
```

...or similar.

## Use…

…`sandbox` flag when you spin up your Rails command line:

```shell
$ heroku run rails console --sandbox
```

You’ll see the following message before your IRB prompt as you log in:

```
Loading development environment in sandbox (Rails 7.0.6)
Any modifications you make will be rolled back on exit
```


## Why?

Trust me, you don’t want to break real customer data in a permanent way. Make a habit of logging into production (and even staging) in sandbox mode.

When you exit the console in sandbox mode all the changes you’ve made to data will be rolled back. This should prevent you from doing anything catastrophic by accident. If you’re just querying data (read only) this mode will give you added reassurance you’re not going to permanently break anything.

You should be aware that if you’re calling code that enqueues jobs (perhaps using sidekiq) or sends email then that code will not be rolled back by the sandbox mechanism, so you should still be careful!


## Why not?

If you’re logging into your production application to deliberately make changes to user data then you’ll need to avoid `sandbox` mode. However I'd recommend seeing if you can test your changes in your `sandbox` before _really_ executing them, then that's a good idea.

In fact if you _are_ making data changes in production it is better to write, test and deploy code to make the required changes, rather than “wing it” in the console. Logging into production `rails console` should feel more scary than it does.