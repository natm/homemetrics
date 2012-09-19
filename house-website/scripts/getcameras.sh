#!/bin/bash
CAMERAPATH=/var/www/house/cameras

# cameras
/usr/bin/wget -q -O $CAMERAPATH/feeder1.jpg http://195.177.253.11/cgi-bin/jpg/image.cgi
/usr/bin/wget --user=admin --password=admin -q -O $CAMERAPATH/feeder2.jpg http://195.177.253.12/GetImage.cgi?CH=0
/usr/bin/wget --user=admin --password= -q -O $CAMERAPATH/frontdoor.jpg http://195.177.253.10/snapshot.cgi
