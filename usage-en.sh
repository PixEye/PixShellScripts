#!/bin/sh

# usage-en.sh

# Created in 1998 by Julien MOREAU aka PixEye

# Last commit of this file (GMT) :
# $Id$
# Local time: $Date$

nbwp=2				# Number of wanted parameters (without options)
cmd=`basename $0`		# Command name
usage="Usage: $cmd [-h]"	# Help message:
usage=$usage"\n\tDisplay this help message.\n"
usage=$usage"\nUsage: $cmd <filename> [...]"
usage=$usage"\n\tCheck parameters number."
usage=$usage"\n\tIf it is not correct, then display an help message."
usage=$usage"\n\n\tThis is just the begining of any quite good shell script.\n"
#usage=$usage"\n\t."

echo "\ntest"|grep -q ntest && e="-e"	# Does 'echo' need the -e option?

if [ "$#" -ne $nbwp -o "$1" = "-h" ] ; then	# Check parameters number
	echo $e $usage 1>&2 ; exit 2		# Display message help and exit
fi

if test ! -r "$1" ; then	# If the file in unreadable:
	echo $e "$cmd: \"$1\" cannot read that file!" 1>&2 ; exit 3
fi


exit 0		# Normal exit

# Prefs for vim editing:
# vim: tabstop=8 shiftwidth=8 textwidth=80
