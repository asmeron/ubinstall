#!/bin/bash

get_list_block_device()
{
	local temp i
	i=0
	temp=(${list_dev_r[@]} $(ls /dev/sd*))

	for line in "${temp[@]}";
	do

		list_dev[$i]=$line
		(( i++ ))
		list_dev[$i]=""
		(( i++ ))

	done
}

auto_prepare_disk()
{

	_dia_inform "Please, Wait..."
	echo ";" | sfdisk $dev >> log.txt
	mkfs.ext4 -F ${dev}1 >> log.txt
	_dia_notify  "Disk Prepare!"

}

manual_prepare_disk()
{
	cfdisk $dev
}
