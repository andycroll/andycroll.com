---
title: "xip.io Doesn’t Work on BT, Fix It"
description: 'Telecom provider modems and routers are terrible for web development.'
layout: article
category: development
redirect_from:
  - /2013/06/21/xip-io-doesnt-work-on-bt/
  - /mac/ruby/xip-io-doesnt-work-on-bt/
image:
  base: '2013/xip-io-doesnt-work-on-bt'
  alt: 'xip.io logo'
---

NB: Don't use pow, use [puma-dev](https://github.com/puma/puma-dev).

-----

I use [pow](http://pow.cx) and [xip.io](http://xip.io) for my local device testing when running Rails apps and ran into a curious issue: it didn’t work at my parent's home. I was getting a 'cannot open the page because the server cannot be found' error.

This is something to do with their network using the BT HomeHub DNS which has locked down the wildcard DNS method that xip.io uses to redirect to your local machine. This might be a feature on other telco-provided ADSL routers.

The fix is simple, use a different DNS server. This is easy to do on Mac & iOS, simply go into the settings for your connected network and enter 1.1.1.1, 1.0.0.1 if you want to use [Cloudflare’s](https://1.1.1.1/dns/).

-----

It'd be great to use a global fix for all devices connected to the wifi network, but BT won’t let you change the DNS server on the HomeHub itself for security reasons.

If you're using the standard ADSL broadband, you'll need to buy a replacement for the home hub. I'm using a simple ZyXEL and linking an Apple Time Capsule to it to provide the wireless network.

If you're using BT Infinity (the fibre broadband) you can just use any wifi access point and connect that directly to the BT Openreach box and configure the DNS on that. I'd use an Apple Time Capsule or Airport Express.
