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
	point=("Create new parents" "" "Format Parent" "" "Back" "")
	_dia_ask_option no "Choose Action" "\n\nPlease Select Action" required "${point[@]}" || return 1
	choose=$ANSWER_OPTION

	if [ "$choose" == "Create new parents" ]; then

		_dia_ask_number "Enter the count parents" "1"
		count=$ANSWER_NUMBER

		for (( i=1; i <= $count; i=i+1 ))
		do
			_dia_ask_number "Enter the size $i parent MB" "10"
			parent=(${parent[@]} $ANSWER_NUMBER)

		done

		disk=""

		for i in "${parent[@]}"
		do

			size=$i
			let "size=size * 2048"
			disk+=",$size\n"

		done

		parent=()

		_dia_inform "Please, Wait..."
		echo -e $disk | sfdisk $dev >> log.txt
		_dia_notify  "Parents Create!"

	fi



fi
