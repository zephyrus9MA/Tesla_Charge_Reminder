#!/bin/bash
# Checks Tesla to see if it is home and plugged in. If not, sends email.

# Define variables
CLIENT_ID=81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384 #standard from app
CLIENT_SECRET=c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3 #standard from app
EMAIL=me@gmail.com # Telsa login
PASSWORD=covid-19 # Telsa password
REFLAT=39.390258   # Where Tesla sees home lat
REFLONG=-119.51741 # Where Tesla sees home long
TOL=.005          # How far from REFLAT/REFLONG is considered home in degrees. 500m =.005 
MAIL_RECIP1=me@gmail.com	#First email recipient
MAIL_RECIP2=8885551212@txt.att.net	#Second email recipient
MAIL_RECIP3=you@gmail.com	#Third email recipient
MAIL_FROM=rocky.racoon@charter.net		#SMTP server FROM address
SMTP_SERVER=smtps://mobile.charter.net:587	#SMTP server:port
MAIL_SERVER_USER_PASS=rocky.racoon@charter.net:MyTree	#SMTP server username:password
charge_port_door_open=asleep  #Handles failure to wake bug

#Echo time stamp
date

#Get access token
result="$(curl -X POST -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW"\
       	-F "grant_type=password" -F "client_id=$CLIENT_ID" -F "client_secret=$CLIENT_SECRET" -F "email=$EMAIL" -F "password=$PASSWORD"\
	"https://owner-api.teslamotors.com/oauth/token")"
#echo "result:'$result'"
access_token=$(awk -F[:,] '{ print $2}' <<< "${result}")
#echo "access_token:'$access_token'"

#Get Vehicle ID
vresult="$(curl  --header "Authorization: Bearer ${access_token//\"/}" "https://owner-api.teslamotors.com/api/1/vehicles")"
#echo "vresult:'$vresult'"
vehicle_id=$(awk -F[:,] '{ print $3}' <<< "${vresult}")
echo "vehicle_id:'$vehicle_id'"

#start door closed loop
#echo "charge port door:'$charge_port_door_open'"

while [ "$charge_port_door_open" != 'true' ] 
do

#Wake up sleepy head
wresult="$(curl --request POST --header "Authorization: Bearer ${access_token//\"/}" "https://owner-api.teslamotors.com/api/1/vehicles/${vehicle_id}/wake_up")"
#echo "wresult:'$wresult'"
sleep 60


#Get charge state
cresult="$(curl  --header "Authorization: Bearer ${access_token//\"/}" "https://owner-api.teslamotors.com/api/1/vehicles/${vehicle_id}/data_request/charge_state")"
#echo "cresult:'$cresult'"
charge_port_door_open=$(awk -F[:,] '{ print $31}' <<< "${cresult}")
echo "charge port door:'$charge_port_door_open'"

#If door is open (true) quit.
if [ "$charge_port_door_open" == 'true' ]
then
	echo Charge port open....quit
	exit
fi

if [ "$charge_port_door_open" != 'false' ]
then
  	echo "wake failure? error in charge_port_door_open:'$charge_port_door_open'"
	exit
fi

#Get location
lresult="$(curl  --header "Authorization: Bearer ${access_token//\"/}" "https://owner-api.teslamotors.com/api/1/vehicles/${vehicle_id}/data_request/drive_state")"
#echo "lresult:'$lresult'"
latitude=$(awk -F[:,] '{ print $7}' <<< "${lresult}")
longitude=$(awk -F[:,] '{ print $9}' <<< "${lresult}")
echo "lat/long: $latitude $longitude"

#check if at home
ltest=$(echo "sqrt(($latitude-$REFLAT)^2) > $TOL"|bc) 
if [ $ltest == 1 ]
	then
		echo Away from Home
		exit
fi

otest=$(echo "sqrt(($longitude-$REFLONG)^2) > )$TOL"|bc)
if [ $otest == 1 ]
	then
		echo Away from Home
		exit
fi
echo "REFLAT, REFLONG, TOL, ltest, otest: $REFLAT $REFLONG $TOL $ltest $otest"

#send message
msg='To: '$MAIL_RECIP1$'\r\nFrom: '$MAIL_FROM$'\r\nSubject: Plug in the Tesla\r\nPlug in the Tesla\r\n'

echo "$msg" | curl --url $SMTP_SERVER --ssl-reqd --mail-from $MAIL_FROM --mail-rcpt $MAIL_RECIP1 --mail-rcpt $MAIL_RECIP2 --mail-rcpt $MAIL_RECIP3 --upload-file . --user $MAIL_SERVER_USER_PASS  --insecure

sleep 3600     #nag after 1 hour

done

exit
