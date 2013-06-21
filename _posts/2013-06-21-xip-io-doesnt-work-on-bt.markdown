---
title: "xip.io Doesn't Work on BT, Fix It"
layout: post
---

I use [pow](http://pow.cx) and xip.io for my local device testing when running Rails apps and ran into a curious issue: it didn't work at my parent's home. I was getting a 'cannot open the page because the server cannot be found' error.

This is something to do with their network using the BT HomeHub DNS which has locked down the wildcard DNS method that xip.io uses to redirect to your local machine. This might be a feature on other telco-provided ADSL routers.

The fix is simple, use a different DNS server. This is easy to do on Mac & iOS, simply go into the settings for your connected network and enter 8.8.8.8, 8.8.4.4 if you want to use Google's. There are other services you can use, such as OpenDNS.

-----

It'd be great to use a global fix for all devices connected to the wifi network, but BT won't let you change the DNS server on the HomeHub itself for security reasons.

If you're using the standard ADSL broadband, you'll need to buy a replacement for the home hub. I'm using the simple [ZyXEL](http://www.amazon.co.uk/dp/B000LE1LXK/ref=nosim?tag=deepcalmcom) and linking an [Apple Time Capsule](http://www.amazon.co.uk/dp/B0058IGPKI/ref=nosim?tag=deepcalmcom) to it to provide the wireless network.

If you're using BT Infinity (the fibre broadband) you can just user any wifi access point and connect that directly to the BT Openreach box and configure the DNS on that. I'd use an [Apple Time Capsule](http://www.amazon.co.uk/dp/B0058IGPKI/ref=nosim?tag=deepcalmcom) or [Airport Express](http://www.amazon.co.uk/dp/B008BEYP26/ref=nosim?tag=deepcalmcom).
