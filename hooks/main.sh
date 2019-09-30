#!/bin/bash


_dia_notify  "Welcome to install UBLinux"

point=("UBLinux Desktop" "" "UBLinux Server" "")
_dia_ask_option no "Choose distrub" "\n\nPlease Select distrub." required "${point[@]}" || return 1
answer=$ANSWER_OPTION
answer=$(echo $answer | cut -d' ' -f2)
answer=${answer,,}

cat ./etc/components.txt | grep "\[$answer\]" | cut -d'|' -f1,2 > temp.txt

