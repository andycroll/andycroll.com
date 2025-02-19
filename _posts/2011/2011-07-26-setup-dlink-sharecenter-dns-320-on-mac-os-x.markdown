---
title: Setup DLink ShareCenter DNS-320 on Mac OS X
description: "NAS setup on macOS."
layout: article
category: other
redirect_from:
  - /2011/07/26/setup-dlink-sharecenter-dns-320-on-mac-os-x-lion/
  - /mac/setup-dlink-sharecenter-dns-320-on-mac-os-x/
image:
  base: "2011/setup-dlink-sharecenter-dns-320-on-mac-os-x"
  alt: "The long forgotten innards of spinning discs"
  credit: "Patrick Lindenberg"
  source: "https://unsplash.com/photos/1iVKwElWrPA"
---

I'd finally had enough of my Drobo's bizarre behaviour (strange slow performance, patchy connection, running _very_ hot, previous data loss) and dreadful desktop software. As it started acting up again in recent weeks I plumped for a 'proper' NAS: a DLink DNS-320.

The in-box manuals for it are terrible though, and you only get a Windows Install CD. Here's how to set it up on Mac using the web interface.

Discovered on [Macworld](https://www.macworld.com/article/181885/pingfind.html) I used the `arp` command to find the IP of the newly connected NAS, by listing all the IPs of devices on your network.

```
arp -a
```

…then try the last IP address in the list in you web browser. It looks like 10.0.1.xx or 192.168.0.xx. If you keep working your way up the list of IP addresses you'll eventually hit on the web interface for the ShareCenter. There's currently no password to the default 'admin' user name so log in and format your drives.

Once all sorted (you might have to log back in due to aggressive timeouts), run the wizard to set your admin password and change the name of the device.

Then you probably want to head get the latest firmware from your local DLink site… mine is in the [EU](https://eu.dlink.com/uk/en/products/dns-320-2-bay-sharecenter-network-storage-enclosure#support) or try somewhere else.

There are dire warnings about installing the correct geographical version, how much of that is true I don’t know, best to be safe though. You might want to grab the updated manual too. You need to find the _Maintenance > Firmware Upgrade_ page.

Then once you've uploaded, rebooted and signed in (using your new password) you can do important stuff like turn on AFP (apple native networking) in _Management > Application Management_.

Sorted. I'm in a [RAID 1](https://en.wikipedia.org/wiki/Standard_RAID_levels#RAID_1_performance) config, so far it seems simpler, faster and more stable than the old Drobo.
