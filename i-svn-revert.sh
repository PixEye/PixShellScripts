#!/bin/sh

# i-svn-revert.sh

# Created in 1998 by Julien MOREAU aka PixEye

# Last commit (GMT time) :
# $Id$
# Local time: $Date$

nbwp=1				# Number of wanted parameters (without options)
cmd=`basename $0`		# Command name
usage="Usage: $cmd [-h]\n\t"	# Help message:
usage=$usage"Display this help message.\n\n"
usage=$usage"Usage: $cmd <filename> [...]\n\t"
usage=$usage"Interactive SVN revert: choose files to revert (or not).\n\t"
usage=$usage"File(s) to revert (or not)."

echo "\ntest"|grep -q ntest && e="-e"	# Does 'echo' need the -e option?

if [ "$#" -lt $nbwp -o "$1" = "-h" ] ; then	# Check parameters number
	echo $e $usage 1>&2 ; exit 2		# Display message help and exit
fi

while [ "$#" -gt 0 ]
do
	if test ! -r "$1" ; then	# If the file in unreadable:
		echo $e "$cmd: cannot read file \"$1\"!" 1>&2
		shift
		continue
	fi

	type less >> /dev/null 2>> /dev/null
	if [ "$?" -eq 0 ]
	then paginate='less'
	else paginate='more'
	fi

	svn diff -x -b "$1" | $paginate
	echo $e "Revert '$1' or Ignore or Quit (y/r/i/n/q)? \c"
	read a
	case "$a" in
		'y'|'Y'|'r'|'R') svn revert "$1" || exit $? ;;
		'i'|'I'|'n'|'N') shift ; continue ;;
		'q'|'Q') exit 0 ;;
		*) echo "What?! "
	esac

	shift
done

exit 0		# Normal exit

# Prefs for vim editing:
# vim: tabstop=8 shiftwidth=8 textwidth=80
