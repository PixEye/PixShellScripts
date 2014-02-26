#!/bin/bash

# By Julien MOREAU aka PixEye

nbwp=2			# Number of wanted parameters
cmd=${0##*/}		# Command name
usage="Usage: $cmd <ext> <filename> [...]"	# Help message
usage=$usage"\n\tAdd an extension to the parameter files."

if test `uname` != "HP-UX" ; then e="-e" ; fi # shall we use the -e option for echo?

if [ "$#" -lt "$nbwp" ] # If there is NOT the right number of parameters,
then echo $e $usage 1>&2 ; exit 2	# Display the help message & stop.
fi

ext="$1" ; shift
while [ $# -ge 1 ]
do mv "$1" "$1.$ext" ; shift
done

exit 0		# Success
