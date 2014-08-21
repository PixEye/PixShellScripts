#!/bin/sh

# usage-en.sh

# Created in 1998 by Julien MOREAU aka PixEye

# Last commit of this file (GMT) :
# $Id$
# Local time: $Date$

nbwp=2				# Number of wanted parameters (without options)
cmd=`basename $0`		# Command name
usage="Usage: $cmd [-h]\n\t"	# Help message:
usage=$usage"Display this help message.\n"
usage=$usage"\n"
usage=$usage"Usage: $cmd <filename> [...]\n\t"
usage=$usage"Check parameters number.\n\t"
usage=$usage"If it is not correct, then display an help message.\n"
usage=$usage"\n\t"
usage=$usage"This is just the begining of any quite good shell script."

echo "\ntest"|grep ntest >> /dev/null && e="-e"	# Does echo need the -e option?

if [ "$#" -ne $nbwp -o "$1" = "-h" ]	# Check parameters number
then echo $e $usage 1>&2 ; exit 2		# Display message help and exit
fi

if test ! -r "$1"	# If the file in unreadable:
then echo $e "$cmd: \"$1\" cannot read that file!" 1>&2 ; exit 3
fi

# Add the main code here

exit 0		# Normal exit

# Prefs for vim editing:
# vim: tabstop=8 shiftwidth=8 textwidth=80 noexpandtab
