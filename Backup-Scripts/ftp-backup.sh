#!/bin/sh
# FTP updload script
#
# Version: 1.0
# Author: Reto Hugi (http://hugi.to/blog/)
# License: GPL v3 (http://www.gnu.org/licenses/gpl.html)
#
# This script is based on work and ideas from http://bash.cyberciti.biz/
#
# Dependencies:
# mail, ncftp
#
# Changelog:
# 2011-03-07 / Version 0.2 / changed mput to put and delete uploaded files
# 2011-03-06 / Version 0.1 / initial release


### System Setup ###
DIR="/backup/filesystem/latest/"

### FTP server Setup ###
FTPD="/backup/"
FTPU="ftp-user"
FTPP="pass"
FTPS="ftp.host.com"

### Other stuff ###
EMAILID="your@mail.com"
NOW=$(date +"%Y-%m-%d")

### Libraries ###
NCFTP="$(which ncftp)"
if [ -z "$NCFTP" ]; then
    echo "Error: NCFTP not found"
    exit 1
fi

MAIL="$(which mail)"
if [ -z "$MAIL" ]; then
    echo "Error: mail not found"
    exit 1
fi


### Dump backup using FTP ###
#Start FTP backup using ncftp
$NCFTP -u"$FTPU" -p"$FTPP" $FTPS<<EOF
mkdir $FTPD
cd $FTPD
lcd $DIR
put -DD *
quit
EOF

### Notify if ftp backup failed ###
if [ "$?" != "0" ]; then
    T=backup.fail
    echo "Date: $(date)">$T
    echo "Hostname: $HOST" >>$T
    echo "Backup failed" >>$T
    echo "." >>$T
    echo "" >>$T
    $MAIL  -s "BACKUP FAILED" "$EMAILID" <$T
    rm -f $T
fi

