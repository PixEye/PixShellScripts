#!/bin/sh

# Written by Julien MOREAU aka PixEye on the 2004-12-23
# Adapted by Julien MOREAU aka PixEye on the 2009-07-29 (using bc instead of expr to support decimal points)

somme=0
while read ligne
do	set 1 $ligne ; shift

	while [ "$#" -ge 1 ]
	do	if test -n "$1"
		then	#echo "$somme + $1"	# for debug use only
			somme=`echo $somme + $1 |bc`
		fi

		shift
	done
done

echo $somme

exit 0
