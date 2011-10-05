#!/usr/bin/bash
#---------- ---------- ---------- ---------- ---------- ----------
#  22.July.2011 -- Shafiq issani - email@shafiq.in
#---------- ---------- ---------- ---------- ---------- ----------
## VARIABLES

ADMINS="email@shafiq.in"        ##id's to be mailed upon success or failure
MYNAME="`basename $0`"          ## Name of this Script
MYHOST="`hostname`"             ## Hostname

TMP=/usr/tmp
LOG=/export/home/hyperion/log.file

date=`date +%Y%m%d`
uname="hyperion"
targetHost="10.50.2.254"
backupSource="/hyperionapp01/Hyperion/"
backupDest="/backup/hyperionapp01backup/"
backupFilename="hyperionapp01_backup_$date"
rsyncDir="/backup/HyperionBackup/"

#---------- ---------- ---------- ---------- ---------- ----------
## PRELIMINARIES

set -x

#Initial message for email content
echo "Hyperion $MYHOST Backup" |tee $LOG

## Welcome Message
echo "---------- ---------- ---------- ----------" |tee -a $LOG
date                                               |tee -a $LOG
echo "$MYNAME : $MYHOST"                           |tee -a $LOG
echo "Begining backup of client systems"           |tee -a $LOG
echo "---------- ---------- ---------- ----------" |tee -a $LOG

echo "rsync'ing $backupSource"   |tee -a $LOG
echo "..." | tee -a $LOG

#mirror data on specified remote server
/usr/local/bin/rsync -avz $backupSource $uname@$targetHost:$rsyncDir |tee -a $LOG

#---------- ---------- ---------- ---------- ---------- ----------
## MAIN BODY
#---------- ---------- ---------- ---------- ---------- ----------
# This script does backups to a rsync backup server. 
# You will end up with a 7 day rotating incremental backup.

#archive and compress directory on specified remote server
ssh -t $uname@$targetHost "tar cf - $rsyncDir | gzip -cf > $backupDest$backupFilename\".tar.gz\"" |tee -a $LOG

#delete files older than 7 days
ssh -t $uname@$targetHost "find $backupDest -name "*.tar.gz" -type f -mtime +7 -exec rm -f {} \;" |tee -a $LOG

#---------- ---------- ---------- ---------- ---------- ----------
## FINISH UP
echo "..." |tee -a $LOG
echo "Finishing Up At: " |tee -a $LOG
echo " " |tee -a $LOG
date | tee -a $LOG
echo " " |tee -a $LOG
echo " " |tee -a $LOG

echo "---------- ---------- ---------- ----------" |tee -a $LOG
date                                               |tee -a $LOG
echo "$MYHOST Directory Listing"				   |tee -a $LOG
echo "---------- ---------- ---------- ----------" |tee -a $LOG
echo "/backup/EssbaseBackup/"					   |tee -a $LOG
ls -ltrh /backup/EssbaseBackup/ 				   |tee -a $LOG
echo "---------- ---------- ---------- ----------" |tee -a $LOG
echo "/backup/OracleBackup/"					   |tee -a $LOG
ls -ltrh /backup/OracleBackup/					   |tee -a $LOG
echo "---------- ---------- ---------- ----------" |tee -a $LOG
echo "/backup/hyperionapp02backup/"			   |tee -a $LOG
ls -ltrh /backup/hyperionapp02backup/ 		   |tee -a $LOG
echo "---------- ---------- ---------- ----------" |tee -a $LOG
echo "---------- -------- END -------- ----------" |tee -a $LOG
echo "---------- ---------- ---------- ----------" |tee -a $LOG
echo " " |tee -a $LOG
echo " " |tee -a $LOG
echo "Note : Please find this log message attached." |tee -a $LOG


uuencode $LOG log.txt>attachment.file

#email report
cat $LOG attachment.file | mailx -s"Hyperion $MYHOST Backup Log" $ADMINS
