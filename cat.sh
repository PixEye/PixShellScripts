#!/bin/sh

while [ "$#" -ge 1 ]
do
	echo
	echo "===== $1 : ====="
	cat "$1"

	shift
done
