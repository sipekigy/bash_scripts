#!/bin/bash


# Query the database
BOOKING="$( mysql -h $SQLSERVER.$REGION.rds.amazonaws.com -P 3306 --ssl-ca=/root/DBLockMon/rds-combined-ca-bundle.pem --ssl-verify-server-cert -u $SQLUSER -p$SQLPASS --execute="select * from bookingengine tralala order by id desc LIMIT 0, 1 \G" dbname)"

ID="$( echo "$BOOKING"|grep "id:"|head -n 1|sed 's/: /=/'| sed 's/ //g' )"
STATUS1="$(echo "$BOOKING"|grep "status:"|head -n 1|sed 's/status: //'| sed 's/ //g')"

echo "$ID"
echo "$STATUS1"


sleep 60

BOOKING2="$(mysql -h $SQLSERVER.$REGION.rds.amazonaws.com -P 3306 --ssl-ca=/root/DBLockMon/rds-combined-ca-bundle.pem --ssl-verify-server-cert -u $SQLUSER -p$SQLPASS --execute="select * from bookingengine tralala order by id desc LIMIT 0, 1 \G" dbname )"

STATUS2="$(echo "$BOOKING2"|grep "status:"|head -n 1|sed 's/status: //'| sed 's/ //g' )"


if [ $STATUS2 == 'pen' ]
then
  #Execute P1

# IAM
#        {
#            "Action": [
#                "SNS:Publish"
#            ],
#            "Resource": [
#                "arn:aws:sns:eu-west-1:$CUSTOMERID:P1notification"
#            ],
#            "Effect": "Allow",
#            "Sid": "AuroraMonitorPublishSNS"
#        },

# SNS
#  aws sns publish --topic-arn arn:aws:sns:$REGION:$CUSTOMERID:P1notification --message "Booking is in pending state in more than 1 minute. Please check the database for possible DB locks Booking ID="$ID""
aws cloudwatch put-metric-data --metric-name DBLockBookingStatus --namespace ApplicationMetrics --value 0 --region eu-west-1


fi

echo "everything is fine"
#date +"%Y-%m-%d_%H-%M-%S"
aws cloudwatch put-metric-data --metric-name DBLockBookingStatus --namespace ApplicationMetrics --value 1 --region eu-west-1

