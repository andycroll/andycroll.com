---
title: "Backing Up Mysql Databases Remotely Using cron & ssh"
description: 'Detailed bash scripts included.'
layout: article
category: development
redirect_from:
  - /2008/03/12/backing-up-mysql-databases-remotely-using-dreamhosts-cron-and-ssh/
image: '2008/backing-up-mysql-databases-remotely-using-dreamhosts-cron-and-ssh'
imagealt: 'Jesus Saves'
imagecredit: 'Photo by [Jason Betz](https://unsplash.com/photos/P9X327-3UyI) on Unsplash'
---

[Dreamhost](http://www.dreamhost.com/r.cgi?134796) can be a great place keep automatic backups of MySQL databases. You are backing up your databases right?

In today's world of database driven blogs ands CMSs like [ExpressionEngine](http://expressionengine.com/index.php?affiliate=deepcalm) losing the the database means losing not only the content but sometimes the design too! Best you keep it backed up hey? Plus it'd be rubbish to lose all those latest thrilling articles.

In my example I'm backing up databases from mediatemple (gs) to Dreamhost. Strictly speaking this method can work for any pair of servers as long as you can run cron jobs on the 'backup' server and ssh to the 'database' server. Cron and ssh? Yes, ladies and gentlemen, we're headed for the command-line. Be brave.

A quick disclaimer, if your database is massive and you're getting huge amounts of un-cached traffic (why!) this might slow your database right down. Most blogs and mid-sized CMS sites are likely to be fine though.

There's three steps to setting this up:

## Set up SSH keys between your servers

You'll need to [set up a new user in the DH Panel](https://panel.dreamhost.com/index.cgi?tree=users.users) and make sure they've got 'shell' access. Let's call them 'mybackup' and give them a good password, the other defaults are fine. You'll also want to note down what server they are on.

Then fire up Terminal in Mac OS X and type...

```
ssh mybackup@server_name.dreamhost.com
```

...where server_name is the server you just noted down when you created the 'backup' user. You'll be asked for your password and might need to agree to the question that appears but after that you'll get a prompt that looks like...

```
[server_name]$
```

Then the cleverness. You then ssh to your database (mt) server. If you're on the (gs) you'll need to type something along the lines of...

```
ssh serveradmin%mt_domain.com@sXXXX.gridserver.com
```

...where mt_domain is your primary domain login (from the control panel) and XXXX is the unique number of your access domain (reached from Server Guide > Access Domains in the (mt) control panel. You'll need your main (mt) password and get another question... agree to it and your prompt will change again!

```
mt_domain.com@cl01:~$
```

If if doesn't connect you'll need to login to the (mt) Control Panel for your primary domain and ensure that the SSH option within 'Server Administrator' is set to be enabled.

If it works? Well done you've connected to the database (mediatemple) server through the backup (Dreamhost) server. Now type...

```
exit
```

...to drop you back to the backup (Dh) server: [server_name]$. Now to build the keys. Make a new directory called .ssh (it might already exist)...

```
mkdir .ssh
```

Then create the keys...

```
ssh-keygen -t dsa
```

Just hit enter to get past the passphrase stuff, it's less secure but we're asking for something to run unattended. Then we need to make the private key only readable by you (for security)...

```
chmod 600 .ssh/id_dsa
```

With that done it's time to put the public key on the database (mt) server...

```
scp .ssh/id_dsa.pub serveradmin%mt_domain.com@sXXXX.gridserver.com:
```

*Don't forget the trailing colon*. And you'll still need to type your password at this stage. Then ssh to you database (mt) server...

```
ssh serveradmin%mt_domain.com@sXXXX.gridserver.com
```

Create the .ssh directory, set the right permissions, append the key to the authorised keys, delete the file and exit...

```
mkdir .ssh
chmod 700 .ssh
cat id_dsa.pub >> .ssh/authorized_keys
rm id_dsa.pub
exit
```

Now you're golden. Your backup user can login from the backup (Dh) server to the database (mt) server without a password. Try...

```
ssh serveradmin%mt_domain.com@sXXXX.gridserver.com
```

See. Cool huh.

## My backup shell script

The following script needs edited to fill in your details. Content for most of the variables (in CAPS) can be found in the mediatemple control panel in the database section.

```
#!/bin/sh
### System Setup ###
NOW=`date +%Y-%m-%d`
KEEPDAYS=5
#
### SSH Info ###
SHOST="sXXXX.gridserver.com"              # XXXX is mt gs number
SUSER="serveradmin%mt_domain.com"         # mt_domain is primary mt domain
SDIR="/home/XXXX/data/tmp"                # XXXX is mt gs number
#
### MySQL Setup ###
MUSER="dbXXXX"                            # XXXX is mt gs number
MPASS="mysqlpass"                         # set to MySQL password
MHOST="internal-db.sXXXX.gridserver.com"  # XXXX is mt gs number
DBS="dbXXXX_db1 dbXXXX_db2"               # space separated list of databases to backup
#
### Local Writable directory on the server ###
EMAILID="name@email.com"                  # the email you want notification sent to
#
### Start MySQL Backup ###
attempts=0
for db in $DBS                            # for each listed database
do
    attempts=`expr $attempts + 1`           # count the backup attempts
    FILE=$SDIR/mysql-$db.$NOW.sql.gz        # Set the backup filename
                                            # Dump the MySQL and gzip it up
    ssh $SUSER@$SHOST "mysqldump -q -u $MUSER -h $MHOST -p$MPASS $db | gzip -9 > $FILE"
done
scp $SUSER@$SHOST:./mysql* .              # copy all the files to backup server
ssh $SUSER@$SHOST rm ./mysql*             # delete files on db server
                                          # deleting of old files on backup
find ./mysql*.sql.gz -type f -daystart -mtime +$KEEPDAYS -exec rm {} \\;
#
### Mail me! ###
localfiles=`ls $LOCALDIR/*.$NOW.sql.gz`
count=0                                   # count local files from today
for file in $localfiles; do count=`expr $count + 1`; done
#
### Send mail ###
mail -s "Backups Report" $EMAILID << END
Success with $count of $attempts
The following databases were attempted backed up
$DBS
Files stored:
$localfiles
END
```

What this file does is, for each database listed in your DBS variable

- dump the database to a file on the database (mt) server
- securely copy it to the backup (Dh) server

Then the dumped files are deleted from the database server and the 5 day old files are deleted from the backup server. The clever little script sends you an email with the details of it's success or failure. Thus if it suddenly stop backing up for some reason you'll know about it.

## Setting up cron

You must uploaded your modified shell script file to the FTP account of your backup user. You'll also need to set the permissions on the script to be executable using your FTP software (I like [Transmit](http://panic.com/transmit)) or you can type...

```
ssh mybackup@server_name.dreamhost.com chmod 744 ./backupsql.sh
```

You'll need to head to the [Cron Jobs section of the Dreamhost Panel](https://panel.dreamhost.com/index.cgi?tree=goodies.cron), and add a new Cron Job, and in the following screen select your backup user, give the job a title, leave the email blank and type...

```
~/backupmt.sh
```

...and set it to run 'Daily'. And with that you should be done.

Whenever you want to backup new databases just add them to the space-separated list in the script. To backup a different server simply take a copy of the script and change the relevant variables and set up a new cron job pointing at the new script.
