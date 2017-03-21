#!/bin/bash


QUER1=$(mysql -h $SQLSERVERNAME.eu-west-1.rds.amazonaws.com -P 3306 --ssl-ca=/root/DBLockMon/rds-combined-ca-bundle.pem --ssl-verify-server-cert -u $SQLUSER -p$SQLPASS --execute="SET @threshold = 30; SELECT p.user, LEFT(p.HOST, LOCATE(':', p.HOST) - 1) host, p.id, TIMESTAMPDIFF(SECOND, t.TRX_STARTED, NOW()) duration, COUNT(DISTINCT ot.REQUESTING_TRX_ID) waiting FROM INFORMATION_SCHEMA.INNODB_TRX t JOIN INFORMATION_SCHEMA.PROCESSLIST p ON ( p.ID = t.TRX_MYSQL_THREAD_ID ) LEFT JOIN INFORMATION_SCHEMA.INNODB_LOCK_WAITS ot ON ( ot.BLOCKING_TRX_ID = t.TRX_id ) WHERE t.TRX_STARTED + INTERVAL @threshold SECOND <= NOW() GROUP BY LEFT(p.HOST, LOCATE(':', p.HOST) - 1), p.id, duration  HAVING duration >= @threshold OR waiting > 0;" )

OUTP1=$(echo "$QUER1"| sed 's/+//g'|sed 's/-//g'|sed 's/\s/,/g')



#echo "$(date +\%Y\%m\%d\%H\%M)" >> /var/log/sqlreport/output.log
#echo "$OUTP1" >> /var/log/sqlreport/output.log


echo -e "$OUTP1" | while read line ; do
   echo "$(date '+%b %d %H:%M:%S') $line" >> /var/log/sqlreport/output.log
done



