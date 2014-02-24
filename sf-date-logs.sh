#!/bin/sh

# Stamp logs of Symfony1.x projects with the date of the last log line
#	(of each file in log/history/). Support gzip compression.
# Tested with sf1.4 (the PHP framework) under Linux with bash & zless installed.
#
# Created on 2012-11-27 by Julien Moreau aka PixEye

for f in log/history/*.log*
do
	echo
	ls -Flh --time-style=long-iso "$f"

	lastl=`zless "$f"|tail -n1`	# last log line
	echo $lastl

	d=`echo $lastl|cut -d' ' -f -3`
	touch -d "$d" "$f" 2> /dev/null || sudo touch -d "$d" "$f"

	ls -Flh --time-style=long-iso "$f"
done
