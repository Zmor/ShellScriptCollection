# Introduction #

Of course you want backups, no intro needed. ;-)
The official, full length how-to for rsnapshot is available at
http://rsnapshot.org/howto/

## Installation ##

`apt-get install rsnapshot`

## Configuration ##

`gksudo gedit /etc/rsnapshot.conf`
(The config file is self-explanatory)

Test the configuration:
`rsnapshot configtest`

...if that worked out, try simulating your backup:
`rsnapshot -t daily`

If that all worked you might want to manually start a backup and watch rsnapshot doing the work:
`rsnapshot daily`

After all went well, set up a cron for the backup:
`crontab -e`

add for example:
```
0 18 * * 0      /usr/bin/rsnapshot weekly
0 20 * * *      /usr/bin/rsnapshot daily
```
For documentation on cron config check [this](http://adminschoice.com/crontab-quick-reference) reference.