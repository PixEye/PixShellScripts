#!/bin/sh

# append2file.sh
# Useful with sudo (instead of ">>")
# Example:
#       $ sudo append2file.sh /etc/hosts 192.168.0.9 foobar

# Created on 2014-02-17 by Julien MOREAU aka PixEye

# Last commit of this file (GMT) :
# $Id$
# Local time: $Date$

nbwp=2				# Number of wanted parameters (without options)
cmd=`basename $0`		# Command name
usage="Usage: $cmd [-h]\n"	# Help message:
usage=$usage"\t Display this help message.\n"
usage=$usage"\n"
usage=$usage"Usage: $cmd <file_path> [<words>]\n"
usage=$usage"\t Add words (extra parameters) or lines (from stdin) to a file.\n"
usage=$usage"\t Useful with sudo."

echo "\ntest"|grep -q ntest && e="-e"	# Does 'echo' need the -e option?

if [ "$#" -lt $nbwp -o "$1" = "-h" ] ; then	# Check parameters number
	echo $e $usage 1>&2 ; exit 2		# Display message help and exit
fi

file_path="$1"
shift

if test ! -w "$file_path" ; then	# If the file in not writable:
	echo $e "$cmd: cannot write file \"$file_path\"!" 1>&2 ; exit 3
fi

if test "$#" -gt 0
then echo $* >> "$file_path"
else
	while read line
	do echo "$line" >> "$file_path" || break
	done
fi

exit 0		# Normal exit

# Prefs for vim editing:
# vim: tabstop=8 shiftwidth=8 textwidth=80
