#!/bin/bash

let argc="$#"

if [ $argc -ne "1" ];
then
	echo "Usage: $0 [dict]"
	echo
	echo "[dict] is a text file, each line of it has the following format:"
	echo '<card> <pass>'
	echo '<card> : 10 digitss'
	echo '<pass> : 4 digits'
	exit
fi

if [ ! -f "$1" ];
then
	echo "error: no such file"
	exit
fi

	
cat "$1" | xargs -n 2 ./get_balance.sh

