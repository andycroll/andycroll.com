---
title: Clean up broken .dev domains
description: Containment is key
layout: article
category: ruby
image:
  base: '2019/clean-up-broken-dev-domains-after-puma-dns_probe_finished_nxdomain'
  alt: 'The insides of your laptop'
  source: "https://unsplash.com/photos/OUgQ3c3OQXE"
  credit: "Nikolai Chernichenko"
---

The brilliant tool [`puma-dev`](https://github.com/puma/puma-dev) is a great way to manage and run rack apps on your local machine in development, particularly on a Mac.

However, `puma-dev` used to default to using the `.dev` suffix on your locally running websites. The default is now `.test`.

As of March 2019, `.dev` domains are now a real top-level domain on the internet, that you can buy. [Use DNSimple](https://dnsimple.com/r/d2b2734a34b81d)! (referral link)

As a long term user of `puma-dev`, you might find that trying to navigate to “live on the internet” `.dev` sites might fail because of the original setup of the tool. In Chrome you see a `DNS_PROBE_FINISHED_NXDOMAIN` error.

Even using the [uninstall instructions](https://github.com/puma/puma-dev#purging) failed to fix this issue for me, **but you should try those first**.

If you have completely uninstalled `puma-dev` and you still can't resolve `.dev` sites here are a few commands to find and destroy the remnants on my machine.

**Last warning: Please use the `puma-dev` uninstaller first. Use these commands at your own risk.**

These commands have been tested on Mac OS 10.14 Mojave.

```shell
# Remove local overwritten resolver for .dev
rm /etc/resolver/dev
# Restart and clear the Mac OS X DNS resolver
sudo killall -HUP mDNSResponder
```

Here are a few other places I found puma-dev files and configuration that weren’t cleaned up by the uninstaller. I delted them too.

```shell
# local site config
~/.puma-dev
# cached install files
/usr/local/Cellar/puma-dev
# cached linked executable
/usr/local/var/homebrew/linked/puma-dev
# generated SSL certificates
~/Library/Application\ Support/io.puma.dev
```

Once I was done wiping it clean... I reinstalled the latest version, all local domains on `.test`. _Worked perfectly._
