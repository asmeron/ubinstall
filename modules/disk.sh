#!/bin/bash

get_list_block_device()
{
	local temp i
	i=0
	temp=(${list_dev_r[@]} $(ls /dev/sd*  && ls /dev/nvme*n*))
	list_dev=()

	for line in "${temp[@]}";
	do

		list_dev[$i]=$line
		(( i++ ))
		list_dev[$i]=""
		(( i++ ))

	done
}

ind_disk()
{
	if [[ $1 =~ 'sd' ]]; then
		echo "1"
	fi

	if [[ $1 =~ 'nvme' ]]; then
		echo "p1"
	fi
}

auto_prepare_disk()
{

	echo ";" | sfdisk $dev >> log.txt
	mkfs.ext4 -F "${dev}${flag}" >> log.txt
	e2label "${dev}${flag}" ublinux

}

manual_partitioning_disk()
{
	cfdisk $dev
}

create_swap()
{
	echo "Create swap file $1 Mb" >> log.txt
}