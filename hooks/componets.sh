#!/bin/bash

inst()
{
	for i in $@
	do

		echo "Install $i" >> log.txt

	done
}


i=0

while read line;
do
	comp[$i]=$(echo $line | cut -d'|' -f1)
	(( i++ ))
	comp[$i]=.
	(( i++ ))
	comp[$i]=OFF
	(( i++ ))

done < "temp.txt"

_dia_ask_checklist "Select Package groups\nDo not deselect base unless you know what you're doing!" 0 "${comp[@]}" || return 1
choose=("${ANSWER_CHECKLIST[@]}")

inst ./components/kernel
for i in "${choose[@]}"
do

	path=$(cat "temp.txt" | grep "$i" | cut -d'|' -f2)
	path=${path/ /}
	inst $path

done

