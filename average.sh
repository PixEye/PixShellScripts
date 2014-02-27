#!/bin/sh

# Written by Julien MOREAU aka PixEye on 2013-02-27
#
# Requires bc

n=0
amount=0

while read ligne
do	set 1 $ligne ; shift

	while [ "$#" -ge 1 ]
	do
		if test -n "$1"
		then	#echo "$amount + $1"	# for debug use only
			n=`expr $n + 1`
			amount=`echo $amount + $1 |bc`
		fi

		shift
	done
done

if [ "$n" -eq 0 ]
then exit 1	# avoid division by zero
fi

# pi=$(echo "scale=10; 4*a(1)" | bc -l)
echo $amount / $n |bc -l

exit 0
