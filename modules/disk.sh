#!/bin/bash


disk=";"
file_system="ext4"

ls /dev/sd* > dev.txt

while read line;
do
	dev[$i]=$(echo $line | cut -d'|' -f1)
	(( i++ ))
	dev[$i]=""
	(( i++ ))

done < "dev.txt"


_dia_ask_option no "Menu Device" "\n\nPlease choose device." required "${dev[@]}" || return 1
dev=$ANSWER_OPTION

point=("Auto Mode" "" "Manual Mode" "" "Back" "")
_dia_ask_option no "Choose Mode" "\n\nPlease Select Mode" required "${point[@]}" || return 1
mode=$ANSWER_OPTION


if [ "$mode" == "Auto Mode" ]; then

	_dia_inform "Please, Wait..."
	echo $disk | sfdisk $dev >> log.txt
	mkfs.$file_system -F ${dev}1 >> log.txt
	_dia_notify  "Disk Prepare!"

fi

if [ "$mode" == "Manual Mode" ]; then

	#_dia_ask_string "Enter the size parent MB" "1024"
	cfdisk $dev

fi
