---
title: "Homebridge and Pi-hole on a Raspberry Pi 4"
description: "Reviving a Pi 4, putting ProWarm underfloor heating thermostats into Apple Home, blocking ads for the whole house, and moving it all onto an SSD."
layout: article
category: other
date: 2026-10-31 09:00
image:
  base: "2026/homebridge-and-pi-hole-on-a-raspberry-pi-4"
  alt: "Raspberry Pi and Homebridge logos repeated at an angle on a white background"
---

I had a Raspberry Pi 4B I thought might be dead. It wasn't. I'm having a bunch of building work done and of course, the thermostats do not work with Apple HomeKit.

So the Pi now runs [Homebridge](https://homebridge.io), which puts our underfloor heating thermostats (and also now [Samsung TVs](https://github.com/tavicu/homebridge-samsung-tizen)) in Apple Home. For good measure it also runs [Pi-hole](https://pi-hole.net), which blocks ads and trackers for every device in the house.

## Gear required

- A Raspberry Pi 4B + USB-C power + micro-HDMI
- A (new) microSD card
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/) on my Mac
- An [Argon ONE](https://argon40.com) case and a USB SSD


## I thought the Pi was dead

First I checked the cheap parts. SD cards and power supplies fail far more often than the Pis themselves.

1. Removed and replaced the SD card.
2. Used the official power supply. Apparently some early Pi 4 boards are buggy with arbitrary USB-C chargers and cables.
3. Plugged into my TV using HDMI. The light was on but the TV stayed blank. That meant a [corrupt bootloader EEPROM](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-boot-eeprom), which is allegedly common on a Pi 4.


### Bootloader recovery

In Raspberry Pi Imager, chose **Raspberry Pi 4**, then **Misc utility images → Bootloader (Pi 4 family) → SD Card Boot**. Wrote it to the new SD card. Booted the Pi from it and waited 10 seconds. Screen went green!


## Homebridge

Flashed the [Homebridge Raspberry Pi image](https://github.com/homebridge/homebridge-raspbian-image) with Raspberry Pi Imager. Set the username, password and Wi-Fi in Imager's customisation step.

1. First boot took **about 5 minutes** to resize and reboot.
2. Opened `http://<ip>:8581` on my Mac.
3. Paired with Apple Home using the QR code on the Homebridge dashboard from the Home app: **+ → Add Accessory**. Needed to accept the "Uncertified Accessory" warning.

Then, I **reserved a fixed IP for the Pi** on my router. Pi-hole needs this later, and it makes everything else easier to find. Fixing a bunch of IPs of home-based things is not a bad idea in my experience.


## ProWarm thermostats

There's no Homebridge plugin for [ProWarm](https://prowarm.com) (!) and the regular app can't talk to anything. However, ProWarm's app is a rebranded [Tuya](https://platform.tuya.com) app.

So the route is ProWarm → Tuya's own **Smart Life** app → [Homebridge](https://github.com/0x5e/homebridge-tuya-platform).

I won't go into the details here: an agent can walk you through the steps, and the thermostats might get replaced anyway if they become more trouble than they're worth.

The most important note is to **keep the schedules on the thermostat**, not in the Home app.

- **Fewer things can break.** The thermostat's schedule runs with no network at all. A Home app schedule needs a home hub, the Pi, Wi-Fi and Tuya's cloud all working at the same moment.
- **Two schedules fight each other.** A Home app schedule and the thermostat's own schedule keep undoing each other.
- **Learning mode needs the thermostat's schedule.** It starts heating early so the floor is warm at the set time. Underfloor heating takes hours to warm up, so this matters.

I use the Home app for temporary overrides, and for "when everyone leaves, set to 16°C" automations. That kind of change only lasts until the next schedule block. If we're away, we use the thermostat's "Holiday Mode".

Schedules, boost, holiday mode and frost protection all run on the thermostat itself. They keep working if the Pi dies. Homebridge is only for info and temporary overrides.


## Pi-hole

A word of warning before you start: once your router points at Pi-hole, every device in the house depends on this Pi to look up websites. _I got this wrong the first time and the whole house lost Wi-Fi._

Also if the Pi dies, nothing loads, which is why I bought the case detailed later to auto-power the Pi. If I ever need to undo it, I'll set the router's DNS back to automatic.


### Getting a terminal

The Homebridge UI has a terminal: **top-right menu → Terminal**. But it logs you in as the `homebridge` service user. Plain `sudo` fails. So I had to switch to my own user (set up in Imager):

```bash
su - <username>
```

SSH from the Mac should also work in theory, but I used the Homebridge terminal.


### Install

```bash
curl -sSL https://install.pi-hole.net | bash
```

- For upstream DNS, I chose [Cloudflare's Family version of 1.1.1.1](https://one.one.one.one/family/).
- Accepted the defaults for blocklist, query logging and privacy level.

Then I set the admin password. This is a separate password, for the Pi-hole web page only:

```bash
sudo pihole setpassword
```


### Port 80 is taken for admin dashboard

The Homebridge image runs nginx on port 80, so `http://<ip>/admin` showed Homebridge, not Pi-hole. Pi-hole's DNS was fine; only the admin dashboard couldn't get the port. So... moved it to 8080:

```bash
sudo pihole-FTL --config webserver.port '8080o,[::]:8080o'
sudo systemctl restart pihole-FTL
```

The admin page is now at `http://<ip>:8080/admin`.


### Pointed my house at it

First I tested on my Mac. In **System Settings → Network → Wi-Fi → Details → DNS**, I added the Pi's IP and removed the other entries. Then I browsed a few sites and watched them appear in Pi-hole's **Query Log**.


#### I have wildly over-specced in-house WiFi

I regret nothing about the levels of Cat6 and the number of UniFi Access Points I own.

My network has a Virgin Media Hub with a [UniFi Express](https://uk.store.ui.com/uk/en/products/ux) behind it, and the UniFi does the routing. Virgin's Hub won't change the DNS it hands out, but UniFi will, and my entire house points at the UniFi.

1. **Set the DNS**: **Settings → Networks → Default**, then the **DHCP** section, then **DNS Server**. Turned off **Auto**, entered the Pi's IP, and left the second box empty. A secondary DNS server gives devices a way round Pi-hole, so I left it blank. The menu moves between UniFi versions, so look for "DHCP DNS Server".
2. **Left the Internet/WAN DNS setting alone.** That's UniFi's own upstream DNS, not what devices get.
3. **Turned off IPv6** on that network. Otherwise devices can get Virgin's IPv6 DNS server and skip Pi-hole.
4. **Reconnected devices** by turning Wi-Fi off and on. Or wait for their leases to renew.

Devices plugged directly into the Virgin Hub, rather than into the UniFi, won't use Pi-hole.

**Checked it worked.** Removed the Pi's IP from the Mac's manual DNS settings, so the list was empty. Then turned Wi-Fi off and on and ran:

```bash
scutil --dns | grep nameserver
```

It listed only the Pi's IP. That proves UniFi is handing it out. If you skip removing the manual entry, the check only shows the setting you typed in yourself.

To undo, set DNS Server back to **Auto**.


### Blocklists

Pi-hole ships with Steven Black's list. I added:

- **[HaGeZi Pro](https://github.com/hagezi/dns-blocklists)**, which blocks a lot but breaks little:
  `https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt`
- **HaGeZi Threat Intelligence Feeds, Medium**, for malware and phishing domains (an add-on):
  `https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.medium.txt`
- **AdGuard Smart TV**, for Samsung TV ads and tracking:
  `https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt`
- **HaGeZi referral allowlist**, added as an **Allow** list. It stops the Pro list breaking shopping and affiliate links:
  `https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-referral-native.txt`

Added each one under **Lists**, then ran **Tools → Update Gravity**.

I kept the default Steven Black list too, because Pi-hole removes duplicate domains when it builds the lists.


#### Why not a big list of lists?

I looked at [Steve Jenkins' Pi-hole list of lists](https://github.com/stevejenkins/pi-hole-lists). It's 21 blocklists, including the ones I added. His regex file allows things for his household (Hulu, USPS, Roku, CrossFit), and blocks patterns like `^analytics`, `^stats` and `^aff` that might break legitimate sites. I want to minimise "home tech support", so I took the Smart TV list and the referral allowlist and left the rest.

When something breaks, usually a shopping link or an email click-tracker, I find the blocked domain in the **Query Log** and click **Allow**.


## Up to date

I don't want to manage this actively.

Blocklists already update weekly on their own. Pi-hole runs the job from cron.


### OS security updates

Turned on [unattended upgrades](https://wiki.debian.org/UnattendedUpgrades):

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```


### Daily blocklist refresh (optional)

HaGeZi updates its lists several times a day. Pi-hole only fetches them weekly. So I fetch them every day:

```bash
echo '15 5 * * * root PATH="$PATH:/usr/local/bin" pihole -g >/var/log/pihole/gravity-daily.log 2>&1' \
  | sudo tee /etc/cron.d/pihole-gravity-daily
```

### Pi-hole, monthly

The manual update is:

```bash
pihole -up
```

I run it from cron at 4:30am on the 1st of each month:

```bash
echo '30 4 1 * * root PATH="$PATH:/usr/local/bin" pihole -up >/var/log/pihole/autoupdate.log 2>&1' \
  | sudo tee /etc/cron.d/pihole-autoupdate
```


### Homebridge plugins

Installed **[Homebridge Updater](https://github.com/homebridge-plugins/homebridge-updater)** (`@homebridge-plugins/homebridge-updater`). It used to be called Homebridge Plugin Update Check. Every auto-update option is off by default.

Turned on:

- **autoUpdatePlugins**
- **autoRestartAfterUpdates**
- **autoUpdateSkipMajorVersions**. Minor fixes install on their own and major versions wait. Seems sensible.

Set **Sensor Type** to **Contact Sensor** and turned on notifications for it in the Home app. It tells me when updates are waiting, and when an automatic one fails.


## The Argon ONE case

Once it was all running, I moved the Pi into [a fancy case](https://thepihut.com/products/argon-one-m-2-raspberry-pi-4-case). It restarts after power loss, cools the board and attaches an SSD through USB.

Had to run Argon's script as my own user, using `su` as above in the Homebridge terminal:

```bash
curl https://download.argon40.com/argon1.sh | bash
```

Now the power button works.


## Move to a USB SSD

SD cards wear out under constant writes, and Pi-hole writes logs all day. So I cloned the SD card onto the SSD.


### Backed up first

Backed up Homebridge and Pi-hole.

- Homebridge UI → **Settings → Backup**.
- Pi-hole UI → **Settings → Teleporter → Export**.


### Clone

Updated the bootloader:

```bash
sudo rpi-eeprom-update -a
```

Installed [Jeff Geerling's maintained fork of rpi-clone](https://github.com/geerlingguy/rpi-clone):

```bash
curl https://raw.githubusercontent.com/geerlingguy/rpi-clone/master/install | sudo bash
```

Cloned, answering **yes** to the prompts:

```bash
sudo rpi-clone sda
```


### Switched over

Set USB boot first: `sudo raspi-config` → **Advanced Options → Boot Order → USB Boot**.

Powered off. Took out the SD card and pressed the power button. Ran `findmnt /` to check it showed `/dev/sda2`.


## Wired up

I've now plugged the Pi directly into the UniFi router and turned off Wi-Fi, reserving the IP address of the wired connection and using that as the DNS server.