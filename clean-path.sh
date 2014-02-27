#!/bin/sh

# Created on 2013-02-18 by J. Moreau aka PixEye
#
# Last commit of this file (GMT):
# $Id$

i=0
np=''
echo "Initial PATH=$PATH"

echo "Please, copy & paste the following line (if any):"

echo $PATH |tr : "\n" | while read a_path
do
	i=`expr $i + 1`

	if test "$a_path" = "."
	then continue
	fi

	if test -d "$a_path"
	then
		export np="$np$a_path:"
		echo "export PATH=$np."
	fi
done | tail -n 1

# Vim editing preferences:
# vim: tabstop=2 shiftwidth=2 noexpandtab
