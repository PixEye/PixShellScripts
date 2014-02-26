#!/bin/sh

# Hosts search by Julien MOREAU aka PixEye

if test "$#" = "0" -o "$1" = "-h" -o "$1" = "--help"
then	cmd=`basename "$0"`
	echo "Usage: $cmd [grep options] <string to look for in hosts file>"
	exit 1
fi

#type ack-grep >> /dev/null 2>&1 && grep="ack-grep" || \
grep="grep -n --color=auto"
grep -v ^'#' /etc/hosts |$grep $*
