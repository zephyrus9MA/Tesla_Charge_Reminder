# Tesla_Charge_Reminder  7/6/20

### Overview
An open port is assumed to be connected 
to a charger. If not, it sends an email to 3 addresses, which can be email-to-text. This process is repeated every hour until corrected.
If not at the defined location, it will check every hour until it is. This script is designed to be run on a timer (e.g. cron or Windows Task Scheduler) 
at a time when the vehicle **should** be on location and plugged in.

### Requirements and Installation
It requires cURL, which is usually installed on a Unix/Linux machine or subsystem. (E.G. with the Windows 10 susbstem for Linux or WSL).
The script and readme can be obtained using git:
`http://git-scm.com/download/`
Install Git if you don't have it.
Then

`$ git clone https://github.com/zephyrus9MA/Tesla_Charge_Reminder.git`

`$ cd Tesla_Charge_Reminder`

You must edit the script (Notepad++ recommended on Windows) to define variables in CAPS.
Here's an example:
`CLIENT_ID=81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384 #standard from app`

`CLIENT_SECRET=c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3 #standard from app`

`EMAIL=me@gmail.com # Telsa login`

`PASSWORD=covid-19 # Telsa password`

`REFLAT=39.390258   # Where Tesla sees home lat`

`REFLONG=-119.51741 # Where Tesla sees home long`

`TOL=.005          # How far from REFLAT/REFLONG is considered home in degrees. 500m =.005` 

`MAIL_RECIP1=me@gmail.com	#First email recipient`

`MAIL_RECIP2=8885551212@txt.att.net	#Second email recipient`

`MAIL_RECIP3=you@gmail.com	#Third email recipient`

`MAIL_FROM=rocky.racoon@charter.net		#SMTP server FROM address`

`SMTP_SERVER=smtps://mobile.charter.net:587	#SMTP server:port`

`MAIL_SERVER_USER_PASS=rocky.racoon@charter.net:MyTree	#SMTP server username:password`


Note that CLIENT_ID and CLIENT_SECRET are generic (you can use these) but could change. 
To run:

`$ bash charge_reminder.sh > output.txt`

in a shell window or Wincows CMD window, or create cron or Task Manager entry.

### Issues
Key issues are a need for vehicle wakeup and email SMTP server requirements. These have been incorporated into the script but could change. An intermittent ongoing Tesla software bug can cause the vehicle not to wake up. 
The code is designed to handle this but has not been tested. SMTP (email) servers are also changing requirements. Code has been tested with both gmail and Charter servers using
the ports that they currently define. gmail requires that the user allow less secure apps to access the server via a Google setting.

