#!/bin/sh

default_ip="www.google.com"

if test "$1" = "-i"
then ip="$2" ; shift 2
else ip="$default_ip"
fi

if [ "$#" -ne 0 ]
then	cmd=`basename $0`
	echo "Usage: $cmd [-i <ip>]"
	echo "\n\tDefault IP to test is: $default_ip"
	exit 1
fi

a_test_failed='false'
while true
do	ping -c1 "$ip" 2>> /dev/null 1>&2 && break
	a_test_failed='true'
	sleep 10
done

if `$a_test_failed` # do not set email alert at the begining
then	echo "IP '$ip' is back."|mailx -s "Net is back!  :-)" `whoami`@localhost
	echo "IP '$ip' is available since"
	date
else echo "Net is already available." # no test failed
fi

exit 0
