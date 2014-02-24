#!/bin/sh

if test "$1" = "-i"
then ip="$2" ; shift 2
else ip="www.google.fr"
fi

if [ "$#" -ne 0 ]
then	cmd=`basename $0`
	echo "Usage: $cmd [-i <ip>]"
	exit 1
fi

while true
do	ping -c1 "$ip" 2>> /dev/null 1>&2 && break
	sleep 10
done

echo "IP '$ip' is back."|mailx -s "Net is back!  :-)" `whoami`

echo "IP '$ip' is available since"
date

exit 0
