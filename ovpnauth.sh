#!/bin/sh
# Config parameters
#PATH=/usr/bin:/bin

conf="/etc/openvpn/ovpnauth.dat"
logfile="/etc/openvpn/ovpnauth.log"

# End of config parameters
md5(){
        echo "$1" > /tmp/$$.md5calc
        sum="`md5sum /tmp/$$.md5calc | awk '{print $1}'`"
        rm /tmp/$$.md5calc
        echo "$sum"
}

log(){
	echo ""
	#echo "`date +'%m/%d/%y %H:%M'` - $1" >> $logfile
}

logenv(){
	enviroment="`env | awk '{printf "%s ", $0}'`"
	echo "`date +'%m/%d/%y %H:%M'` - $enviroment" >> $logfile
}


log "auth called"

if [ "$1" = "" ] || [ "$1" = "help" ]
then
	echo "ovpnauth.sh v0.1 - OpenVPN sh authentication script with simple user db"
	echo "                   for use withauth-user-pass-verify via-file option"
	echo ""
	echo "help - prints help"
	echo "md5 password - to compute password md5 checksum"
	exit 1
fi

if [ "$1" = "md5" ]
then
        echo `md5 $2`
	exit 1
fi

username=`awk 'NR==1' "$1"`
password=`awk 'NR==2' "$1"`
storedpass=password

# computing password md5
password=`md5 $password`
storedpass=`cat $conf | grep $username= | awk -F= '{print $2}'`

if [ "$password" = "$storedpass" ] 
then
	log "OpenVPN authentication successfull: $username"
	#logenv
	exit 0
fi

log "OpenVPN authentication failed: $username"
#logenv
exit 1

