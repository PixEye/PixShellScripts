#!/bin/sh

# cvs-sync.sh
#
# This script synchronizes the local folder with a CVS repository
#
# Parameter: the global commit comment
#
# Created on 2004-12-14 by Julien MOREAU
#
# Last commit of this file (GMT):
# $Header: /cvs/CVS-tools/cvs-maj.sh,v 1.5 2012-11-23 10:08:38 jmoreau Exp $

cmd=`basename $0`	# This file name (without folder path)
comment="$*"		# Global commit comment
cwd='.'				# Current Way Directory

# File containing the list of files to add to the CVS repository:
files2add=~/tmp/CVSfiles2add.tmp	# it is also a lock

mkdir -p ~/tmp		# Create a temporary folder if it does not exist already
if test -f "$files2add"
then
	echo -e "\n The lock file: \"$files2add\" already exists!\n" 1>&2
	echo -e "Another $cmd may be still running." 1>&2
	echo -e "You may remove the temporary lock file\n" 1>&2
	echo -e " and then run again $cmd" 1>&2
	exit 1
fi
> "$files2add"		# Reset list of files to add to the CVS repository

echo "cvs status (to know it there is any conflict or files to add)"
cvs status 2>&1 | grep -v ^$ | sed 's/^[        ]*//' | while read ligne
do
	# Find the line title (20 char max):
	line_title=`echo $ligne|cut -d':' -f1|cut -c-20`

	# Extract suffix of the line (all except title):
	line_suffix=`echo $ligne|cut -d':' -f2-`

	# Test if "(none)" is present or if a version is locked:
	echo "$ligne"|grep -q '(none)'
	none_present=$?

	case "$line_title" in
		"cvs server") mot1=`echo $line_suffix|cut -d' ' -f1`
			if test "$mot1" = "Examining"
			then
				# Get the current target folder:
				cwd="`echo $line_suffix|cut -d' ' -f2-`"
			else
				echo "Unknown CVS error:" 1>&2
				echo $ligne 1>&2
				exit 2
			fi ;;
		"====================") ;;
		"File") # Set the line suffix in $1 $2 ...:
			set 1 $line_suffix
			shift

			# Get the filename:
			if test "$1 $2" = "no file" ; then shift 2 ; fi
			filename="$1"
			shift
			while test ! "$1" = "Status:"
			do
				filename="$filename $1"
				shift
			done

			# Get the CVS status of the file:
			shift
			status="$*"
			case "$status" in
				"Up-to-date") ;;
				"Locally Modified") ;;
				"Needs Checkout") ;;
				*)	echo -e "\nUnknown status and/or invalid:"
					echo -e "$status\tfor the file: $filename"
				;;
			esac

			# Display the progress (file by file):
			#echo -e "$status\t$filename"
			echo -e ".\c"
			;;
		"Working revision") ;;
		"Repository revision") ;;
		"Sticky Tag"|"Sticky Date"|"Sticky Options")
			if [ $none_present -eq 1 ]
			then echo -e "\n$cmd warning: $cwd/$filename -> $ligne"
			fi ;;

		*)	mot1=`echo $line_title|cut -d' ' -f1`
			if test "$mot1" = '?'
			then
				set 1 $ligne
				shift 2
				file2add="$*"
				# If it's a folder, add the inner files as well:
				if test -d "$file2add"
				then
					echo -e "New folder to add: \"$file2add\""
					find "$file2add"|while read f
					do
						echo "$f" >> "$files2add"
					done
				else
					echo -e "New file to add: \"$file2add\""
					echo "$file2add" >> "$files2add"
				fi
			else
				echo -e "\nUnknown line:\n$ligne" 1>&2
				echo -e "Title: $line_title" 1>&2
				exit 3
			fi ;;
	esac
done

# List of files to add:
if test -s "$files2add"
then
	echo -e "\nList of files to add:"
	cat "$files2add"
	set 1 `cat "$files2add"`
	shift
	liste2add="$*"

	# The cvs add:
	echo -e "cvs add $liste2add"
	cvs add $liste2add || exit $?
else
	echo "No file to add in the CVS repository."
fi
rm -f "$files2add"

echo
if test -z "$comment"
then
	echo "You must provide a comment as the parameter(s)!" 1>&2
	exit 4
fi

# The cvs commit:
echo "cvs commit -m \"$comment\""
cvs commit -m "$comment" || exit $?

# The cvs update:
echo "cvs update (to retrieve potential new files)"
cvs update

# Preferences for vim editing:
# vim: noexpandtab tabstop=4 shiftwidth=4
