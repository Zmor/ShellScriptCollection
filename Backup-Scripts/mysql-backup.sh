#!/bin/bash
# Shell script to backup MySql databases
#
# Version: 1.0.1
# Author: Reto Hugi (http://hugi.to/blog/)
# License: GPL v3 (http://www.gnu.org/licenses/gpl.html)
#
# This script is based on work and ideas from http://bash.cyberciti.biz/
#
# Dependencies:
# mysql, mysqldump, chown, chmod, gzip
#
# Changelog:
# 2011-08-05 / Version 1.0.1 / Compatibility Update with new mysqldump version
# 2011-03-06 / Version 1.0 / initial release
 
MyUSER="user"       # USERNAME
MyPASS="pw"         # PASSWORD
MyHOST="localhost"  # Hostname

# If cleanup is set to "1", backups older than $OLDERTHAN days will be deleted!
CLEANUP=1
OLDERTHAN=60
 
# Backup Dest directory
DEST="/backup/mysql"
 
# Directory, where a copy of the "latest" dumps will be stored
LATEST=$DEST/latest
 
# Get hostname
HOST="$(hostname)"
 
# Get data in dd-mm-yyyy format
NOW="$(date +"%Y-%m-%d")"

# DO NOT BACKUP these databases (separate database names by space)
EXCLUDE=""


### Libraries ###
MYSQL="$(which mysql)"
if [ -z "$MYSQL" ]; then
    echo "Error: MYSQL not found"
    exit 1
fi
MYSQLDUMP="$(which mysqldump)"
if [ -z "$MYSQLDUMP" ]; then
    echo "Error: MYSQLDUMP not found"
    exit 1
fi
CHOWN="$(which chown)"
if [ -z "$CHOWN" ]; then
    echo "Error: CHOWN not found"
    exit 1
fi
CHMOD="$(which chmod)"
if [ -z "$CHMOD" ]; then
    echo "Error: CHMOD not found"
    exit 1
fi
GZIP="$(which gzip)"
if [ -z "$GZIP" ]; then
    echo "Error: GZIP not found"
    exit 1
fi
CP="$(which cp)"
if [ -z "$CP" ]; then
    echo "Error: CP not found"
    exit 1
fi
 
[ ! -d $DEST ] && mkdir -p $DEST || :
[ ! -d $LATEST ] && mkdir -p $LATEST || :
 
# Only root can access it!
#$CHOWN 0.0 -R $DEST
#$CHMOD 0600 $DEST
 
# Get a list of all databases available
DBS="$($MYSQL -u$MyUSER -p$MyPASS -h $MyHOST -Bse 'show databases')"

# start dumping databases
for db in $DBS
do
    skipdb=-1
    if [ "$EXCLUDE" != "" ];
    then
	for i in $EXCLUDE
	do
	    [ "$db" == "$i" ] && skipdb=1 || :
	done
    fi
 
    if [ "$skipdb" == "-1" ] ; then
	    FILE="$DEST/$db.$HOST.$NOW.gz"
	    # do all in one job in pipe,
	    # connect to mysql using mysqldump for select mysql database
	    # and pipe it out to gz file in backup dir :)
        $MYSQLDUMP -u$MyUSER -p$MyPASS -h $MyHOST --single-transaction $db | $GZIP -9 > $FILE
        $CP $FILE "$LATEST/$db.$HOST.latest.gz"
    fi
done

# Remove files older than x days if cleanup is activated
if [ $CLEANUP == 1 ]; then
    find $DEST/ -name "*.gz" -type f -mtime +$OLDERTHAN -delete
fi

