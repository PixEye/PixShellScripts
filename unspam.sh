#!/bin/sh

# unspam.sh
#
# To use with bogofilter

# 2005-05-15 Created by Julien Moreau aka PixEye

nbwp=1				# Number of wanted parameters (without options)
cmd=`basename $0`		# Command name
tmp='/tmp/bogo-sh.tmp'		# Temporary file
usage="Usage: $cmd [-h]"	# Help message:
usage=$usage"\n\t"
usage=$usage"Display this help message.\n"
usage=$usage"\n"
usage=$usage"Usage: $cmd <filename>\n\t"
usage=$usage"Unspam mails in a given file."

echo "\ntest"|grep -q ntest && e="-e"	# echo a-t'il besoin de l'option -e ?

if [ "$#" -ne $nbwp -o "$1" = "-h" ] ; then	# Check parameters number
	echo $e $usage 1>&2 ; exit 2		# Display message help and exit
fi

if test ! -r "$1" ; then	# If the file in unreadable:
	echo $e "$cmd: \"$1\" cannot read that file!" 1>&2 ; exit 3
fi

echo "Before:"
grep ^'X-Bogosity: ' "$1"

bogofilter -e -p -o 0.47 -Sn < "$1" > "$tmp"

echo "After:"
grep ^'X-Bogosity: ' "$tmp"

#mv -i "$tmp" "$1"
mv -f "$tmp" "$1"

# Prefs for vim editing:
# vim: tabstop=8 shiftwidth=8 textwidth=80
