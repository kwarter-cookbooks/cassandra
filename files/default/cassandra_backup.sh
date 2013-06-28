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

find ${BackupPath}/*tar* -atime +7 -exec rm {} \;

 ${AppBinPath}/nodetool snapshot ${Keystore}

for cf in `ls ${AppDataDir}/${Keystore}/ | xargs -n 1 basename`;
  do 
    if [ -d ${AppDataDir}/${Keystore}/${cf}/snapshots]; then 
      LatestCopy=`ls -rt ${AppDataDir}/${Keystore}/${cf}/snapshots/ | tail -1`;
	    BackupFileName="`hostname`.$Keystore.${cf}.$DateStamp";
      sudo rsync -ar ${AppDataDir}/${Keystore}/${cf}/snapshots/${LatestCopy} ${BackupPath}/${BackupFileName};                      
      sudo tar -czvf ${BackupPath}/${BackupFileName}.tar -C ${BackupPath} ${BackupFileName};
      s3cmd put ${BackupPath}/${BackupFileName}.tar s3://backups.kwarter.com/`hostname |cut -d"." -f2`/;
      rm -rf ${BackupPath}/${BackupFileName};
    else
    	echo "${AppDataDir}/${Keystore}/${cf}/snapshots does not exist";
    fi
done
