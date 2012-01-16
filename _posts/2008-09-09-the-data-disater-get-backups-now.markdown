---
title: "The Data Disaster, Get Backups Now"
layout: post
---

I arrived in Melbourne last week, for a three week stay keeping my lovely other half company away from Manila. I started a morning's work in the apartment, only to find the internet crawling at dial-up speeds, so I quickly aimed for a nearby coffee shop. However when I opened the MacBook, light-blue screen: no life. I forced the machine to reboot, light-blue screen: no life.

Now I should mention that I am a good boy. I have Time Machine backup running on a USB drive attached to my Airport, and I also regularly (2 or 3 times a week) do a full backup to the same drive. However, this drive was in Manila not Melbourne.

Thankfully I had noticed over the previous few weeks, that my Mac was behaving a little curiously; inaccessible desktop icons, non-closing programs, occasional misbehaviour when opening from sleep. I hadn't realised that I was on the verge of catastrophic failure, but I *did* have my Leopard install discs.

## Hooray for DiskWarrior

After a quick trip to [MyMac](http://www.mymac.com.au/) and the kind loan of a Leopard install disk to confirm, via Disk Utility, that the HD was truly screwed. They couldn't take on the rebuild of the Machine as they we're backed up 8-10 days!

I'd purchased [Disk Warrior](http://www.alsoft.com/DiskWarrior/index.html) a few months back to try and retrieve some data from a busted external disk drive, so I booted from that and a couple of hours later it had managed to discover all my files! However the disk was a write off, time to hit the shops.

I bought a couple of 250GB SATA drives for $140 AUD each, and an enclosure for one of them, in order to prepare myself for the backup schedule I clearly need.

I installed one drive in the enclosure and retrieved my home directory from the damaged machine and then fitted the new drive to the MacBook and reinstalled Leopard, thank goodness it's a [simple procedure](http://manuals.info.apple.com/en/MacBook_13inch_HardDrive_DIY.pdf.) I recommend you attempt this with the recommended screwdrivers, rather than using tweezers and nail clippers as I did. It did work though. Needs must.

## My Solid Backup Schedule

So now I'm back up to speed (a 500MB System Update later) and instigating a improved backup plan.

**Every night** plug in the identically sized external hard disk and use [SuperDuper!](http://www.shirt-pocket.com/SuperDuper/) to perform a full clone of my main disk. This disk will come with me to wherever I am sleeping, but not 'on-the-road' during the day. It's only a 2.5" HD so it's pretty portable.

This way if the main disk fails I can just replace directly and be up and going in no time, rather than the day or two its taken to get back up to speed! Or should the MacBook itself fail I could use the drive externally on any other Mac. This full 'portable backup' is more important than I realised.

I'll get back onto Time Machine when I get back to my 'base', but it's more of a local, no-brainer version control than backup protection for me.

### Offsite

Obviously my programming is backed up using [GitHub](http://github.com/andycroll).

I've been using [Mozy](http://mozy.com) as an offsite backup solution for important non-version controlled stuff (photos et al.) and it seems to work ok, but I'll be interested to see how [Dropbox](http://getdropbox.com) develops in the future, being able to track directories (web bookmarks, address book) would sell me immediately.

I've been using [MobileMe](http://me.com) recently as a trial but I think I'm going to go back to plain Gmail/Gcal and reinvesting in [Spanning Sync](http://spanningsync.com/) or [BusySync](http://www.busymac.com/), but I'll hang on until I'm back in Singapore and an iPhone owner though. Just in case...

##Joni Mitchell

[You don't know what you've got 'til it's gone](http://www.lyricsfreak.com/j/joni+mitchell/big+yellow+taxi_20075370.html).

Get a full backup of your hard disk *right now*. Particularly if you move around as much as me, your machine can take more of a beating that you realise. Plus it can take a while to reinstall your environment just the way you like it.