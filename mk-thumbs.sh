#!/bin/sh

# mk-thumbs.sh

# 2005-05-15 PixEye@bigfoot.com	Creation

nbps=1				# Number of wanted parameters (without options)
geometry="160x120"		# Maximum thumbnail size
tool="convert"			# Requires this tool as sub-program
thumbdir=".thumbnails"		# Thumbnails directory
cmd=`basename $0`		# Command name
usage="Usage: $cmd -h"		# Help message:
usage=$usage"\n\tDisplay this help message.\n"
usage=$usage"\nUsage: $cmd [-n] [-g <geometry>] <pictures> [...]"
usage=$usage"\n\tMakes thumbnails from current directory pictures."
usage=$usage"\n\tThis script requires $tool (from the ImageMagick package)."
usage=$usage"\n\tThe default geometry for thumbnails is $geometry.\n"
usage=$usage"\n\tThe -n option avoid already existing thumb overwriting."

if test `uname` != "HP-UX" ; then e="-e" ; fi

if [ "$#" -ge 1 -a "$1" = "-n" ] ; then optn=true ; shift ; else optn=false ; fi
if [ "$#" -ge 2 -a "$1" = "-g" ] ; then geometry="$2" ; shift 2 ; fi

if [ "$#" -lt $nbps -o "$1" = "-h" ]	# Check parameters number
then echo $e $usage ; exit 2			# Display help message and exit
fi

ltool=`type -p $tool|grep -v "no $tool in "`	# Long name of the tool
if test -z "$ltool"
then echo $e "$cmd: This script requires $tool." ; exit 1
fi

while [ "$#" -ge 1 ]	# Better than a "for" (case of filenames with spaces)
do
	file="$1"
	if test ! -r "$file"
	then echo "$cmd: $file not readable!" 1>&2 ; shift ; continue
	fi

	if test -d "$file"
	then echo "$cmd: $file is a directory!" 1>&2 ; shift ; continue
	fi

	mkdir -p `dirname "$file"`"/$thumbdir"
	thumb=`dirname "$file"`"/$thumbdir/"`basename "$file"`
	echo $e "$file ... \c"

	if test -r "$thumb" && "$optn"
	then echo "already existing." ; shift ; continue
	fi

	"$ltool" -geometry "$geometry" -interlace Plane "$file" "$thumb" \
		&& echo OK

	shift
done

exit 0

# Prefs for vim editing:
# vim: ts=8 sw=8 tw=80 noet
