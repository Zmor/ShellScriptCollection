#!/bin/sh
# Filesystem backup script
#
# Version: 1.1.1
# Author: Reto Hugi (http://hugi.to/blog/)
# License: GPL v3 (http://www.gnu.org/licenses/gpl.html)
#
# This script is based on work and ideas from http://bash.cyberciti.biz/
#
# Dependencies:
# tar
#
# Changelog:
# 2011-08-05 / Version 1.1.1 / fixed comparison syntax
# 2011-03-07 / Version 1.1 / introduced numbering of latest incremental
# 2011-03-06 / Version 1.0 / initial release


### System Setup ###
# all paths for the DIRS variable must be relative to the root (don't start with /)
DIRS="etc backup/mysql/latest var/www/vhosts"
BACKUPDIR="/backup/filesystem"
# Directory, where a copy of the "latest" dumps will be stored
LATEST=$BACKUPDIR/latest

# Day of Week (1-7) where 1 is monday
FULLBACKUP="7"

# If cleanup is set to "1", backups older than $OLDERTHAN days will be deleted!
CLEANUP=1
OLDERTHAN=14

### Other stuff ###
INCFILE=$BACKUPDIR/tar-inc-backup.dat
#BACKUP=$BACKUPDIR/ftp.$$
NOW=$(date +"%Y-%m-%d")
DAY=$(date +"%u")
HOST="$(hostname)"

### Libraries ###
TAR=$(which tar)
if [ -z "$TAR" ]; then
    echo "Error: tar not found"
    exit 1
fi
CP="$(which cp)"
if [ -z "$CP" ]; then
    echo "Error: CP not found"
    exit 1
fi

### Start Backup for file system ###
[ ! -d $BACKUPDIR ] && mkdir -p $BACKUPDIR || :
[ ! -d $LATEST ] && mkdir -p $LATEST || :

if [ $DAY -eq $FULLBACKUP ]; then
  FILE="$HOST-full_$NOW.tar.gz"
  $TAR -zcPf $BACKUPDIR/$FILE -C / $DIRS
  $CP $BACKUPDIR/$FILE "$LATEST/$HOST-full_latest.tar.gz"
else
  FILE="$HOST-incremental_$NOW.tar.gz"
  $TAR -g $INCFILE -zcPf $BACKUPDIR/$FILE -C / $DIRS
  $CP $BACKUPDIR/$FILE "$LATEST/$HOST-incremental_latest_$DAY.tar.gz"
fi

### Find out if ftp backup failed or not ###
# Remove files older than x days if cleanup is activated
if [ $CLEANUP == 1 ]; then
    find $BACKUPDIR/ -name "*.gz" -type f -mtime +$OLDERTHAN -delete
fi


