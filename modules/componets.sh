#!/bin/bash

inst()
{
	local i
	
	for i in $@
	do
		cp -R $1/* /mnt 
		echo "Install $i" >> log.txt

	done
}

get_list_components()
{
	local i line

	i=0

	while read line;
	do
		list_comp[$i]=$(echo $line | grep "\[$distr\]" | cut -d'|' -f1,2)
		
		if [ "${list_comp[$i]}" != "" ]; then
			(( i++ ))
		fi

	done < "./etc/components.txt"

	i=0

	for line in "${list_comp[@]}";
	do

		list_comp_name[$i]=$(echo $line | cut -d'|' -f1)
		(( i++ ))
		list_comp_name[$i]=.
		(( i++ ))
		list_comp_name[$i]=OFF
		(( i++ ))

	done
}


get_list_distrub()
{
	list_distrub=("Ublinux Desktop" "" "Ublinux Server" "")
}

install_components()
{
	local i j

	mount "${1}" /mnt

	for j in "${comp[@]}"
	do

		while [[ "${list_comp[$i]}" != "$j"* ]]; 
		do
			(( i++ ))
		done
	
		path=$(echo "${list_comp[$i]}" | grep "$j" | cut -d'|' -f2)
		path=${path/ /}
		i=0
		inst $path

	done

	genfstab -U /mnt >> /mnt/etc/fstab
}

