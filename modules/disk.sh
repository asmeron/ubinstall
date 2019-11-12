#!/bin/bash

get_list_block_device()
{
	local temp i
	i=0
	temp=(${list_dev_r[@]} $(ls /dev/sd*))
	list_dev=()

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

	echo ";" | sfdisk $dev >> log.txt
	mkfs.ext4 -F ${dev}1 >> log.txt
	e2label ${dev}1 ublinux

}

manual_partitioning_disk()
{
	cfdisk $dev
}

create_swap()
{
	echo "Create swap file $1 Mb" >> log.txt
}