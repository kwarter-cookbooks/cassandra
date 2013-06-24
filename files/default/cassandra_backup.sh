#!/bin/bash

## Set variables 
AppName=cassandra
TodayDate=`date +"%d/%b/%g %r"`
DateStamp=`date +%Y%m%d%H%M`
CurrentTime=`date +"%r"`
AppBinPath="/usr/bin"
LogFile="/tmp/$AppName-backup-$DateStamp_$CurrentTime.log"
IsOK=0
CmdStatus=""
BackupPath="/var/backups"
Keystore="$1"
AppDataDir="/var/lib/cassandra/data"

find ${BackupPath}/* -atime +7 -exec rm {} \;

for cf in `ls ${AppDataDir}/${Keystore}/ | xargs -n 1 basename`;
  do 
    LatestCopy=`ls -rt ${AppDataDir}/${Keystore}/${cf}/snapshots/ | tail -1`;
	  BackupFileName="`hostname`.$Keystore.${cf}.$DateStamp";
    sudo rsync -ar ${AppDataDir}/${Keystore}/${cf}/snapshots/${LatestCopy} ${BackupPath}/${BackupFileName};                      
    sudo tar -czvf ${BackupPath}/${BackupFileName}.tar -C ${BackupPath} ${BackupFileName};
    sudo gzip ${BackupPath}/${BackupFileName}.tar;
    s3cmd put ${BackupPath}/${BackupFileName}.tar.gz s3://backups.kwarter.com/`hostname |cut -d"." -f2`;
    rm -rf ${BackupPath}/${BackupFileName};
done