#!/bin/bash

Host=""
Domen=""
User_name=""
User_pass=""


_dia_ask_string "Enter the Host Name" "ublinux-sample"
Host=$ANSWER_STRING

_dia_ask_string "Enter the Domen" "local.domean"
Domen=$ANSWER_STRING

_dia_ask_string "Enter the User Name" "superadmin"
User_name=$ANSWER_STRING

_dia_ask_string "Enter the password for $User_name" "123"
User_pass=$ANSWER_STRING



echo -e "name = $Host\ndomen = $Domen\nuser = $User_name\npassword = $User_pass" > ./etc/base.conf