# Introduction #
This how-to describes a backup strategy for a web servers httpdocs and its (local) MySQL database. It includes local full and incremental backup storage as well as remote (ftp) server backup storage and history managment (i.e. removing old, useless backups).

# Overview #
In regard to the pattern "divide and conquer" the backup job is divided to three shell scripts, all responsible for their specific task:
  * [mysql-backup.sh](mysql-backup.sh)
  * [file-backup.sh](file-backup.sh)
  * [ftp-backup.sh](ftp-backup.sh)

All configured properly and called via cron deamon this is all it takes for our backup.

# MySQL Backup #
The MySQL backup script - you guessed it - is responsible for the DB backups. It's simply dumping MySQL databases into a specified directory and adds a time stamp to the dump. Additionally the latest backup is stored in the "latest" folder, ready to be picked up and transfered to the ftp server from the ftp-backup.sh script.

## Dependencies ##
The script requires mysql, mysqldump, chown, chmod and gzip to work as expected.

## Configuration ##
The following configuration should be almost self-explanatory (edit your local copy of mysql-backup.sh:
```
MyUSER="user"     # USERNAME (use an admin user with enough rights)
MyPASS="pw"       # PASSWORD
MyHOST="localhost"          # Hostname

# If cleanup is set to "1", backups older than $OLDERTHAN days
# will be deleted!
CLEANUP=1
OLDERTHAN=60
 
# Backup Dest directory
DEST="/backup/mysql"
 
# Directory, where a copy of the "latest" dumps 
# will be stored (this is required for the ftp backup
# to work with mysql backups.
LATEST=$DEST/latest
 
# Get data in dd-mm-yyyy format (again, no need to adjust 
# if you're ok with the format)
NOW="$(date +"%Y-%m-%d")"

# DO NOT BACKUP these databases (separate database names by space)
EXCLUDE=""
```

# File System Backup #
The file-backup.sh script is responsible for backing up - you guessed it - the file system. It's doing full and incremental backups by using tar.

## Dependencies ##
The script requires tar to work as expected.

## Configuration ##
```
### System Setup ###
# all paths for the DIRS variable must be relative
# to the root (don't start with /).
# Include all directories you whish to backup. Of course you
# need to include the myslq/latest directory if you whish to
# include the mysql dumps in your ftp backup.
DIRS="etc backup/mysql/latest var/www/vhosts"

# This is where the backup archives will be stored
# choose a mount that has enough space to hold a couple of full backups.
BACKUPDIR="/backup/filesystem"

# Directory, where a copy of the "latest" dumps will be stored
# the "latest" dumps will be removed by the ftp-backup.sh script once
# the upload tho the ftp server was successful. 
LATEST=$BACKUPDIR/latest

# Day of Week (1-7) where 1 is monday.
# Defines the day on which a full backup should be created.
# The script will create incremental backups on the other 6 days
FULLBACKUP="7"

# If cleanup is set to "1", backups older than $OLDERTHAN
# days will be deleted!
CLEANUP=1
OLDERTHAN=14
```

# FTP Backup #
The ftp-backup.sh script simply picks up the "latest" backup written by the file-backup.sh script and uploads them to an ftp server directory.

## Dependencies ##
The script requires mail and ncftp to work as expected.

## Configuration ##
```
### System Setup ###

# this is where the file-backup.sh script stores it's latest backups
# (full and incremental)
DIR="/backup/filesystem/latest/"

### FTP server Setup ###
FTPD="/backup/"     # absolute path to remote directoy on ftp server
FTPU="ftp-user"     # ftp user
FTPP="pass"         # ftp user password
FTPS="ftp.host.com" # ftp host address

### Other stuff ###
# e-mail address where you whish to get alerts
# sent to if the ftp-backup fails
EMAILID="your@mail.com" 
```

# Cron Jobs #
As already mentioned we need a working cron deamon to get the backup up and running.
  1. create a file called "backups" (or whatever you like in /etc/cron.d/
```
touch /etc/cron.d/backups
```
  1. add the following lines to the newly created file
```
# Backup schedule plan

# MySQL Dumps every night at 2 o'clock
0 2	* * *	root	/backup/scripts/mysql-backup.sh

# Filesystem backups every night at 2:30
30 2	* * *	root	/backup/scripts/file-backup.sh

# FTP Transfer of latest backups every night at 4:30
30 4	* * *	root	/backup/scripts/ftp-backup.sh > /dev/null 2>&1
```

That's about it. You've now set up a pretty complete backup strategy for your web server.

## Restore
A word about restore ;-)

To restore a backup, copy the .tar.gz files into a directory and run the commands:

`tar -xzpf servername-full_latest.tar.gz`

`tar --incremental -xzpf servername-incremental_latest_1.tar.gz`

`tar --incremental -xzpf servername-incremental_latest_2.tar.gz`

and so on until all the incremental files are extracted.

You then need to recreate your mysql database and users, and then you'll run:

`mysql -u username -p_password database_name < dbname.servername.latest`
