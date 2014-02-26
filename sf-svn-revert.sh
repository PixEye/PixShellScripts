#!/bin/sh

# sf-svn-revert.sh
#
# This script (SVN) reverts small changes on Symfony (PHP) files placed in lib/*/
# The idea is that files where only the date changed have no sense to be commited.
# This can happen for example after a:
#       $ php symfony propel:build-model
# ...or a "build-forms" or a "build-filters".
#
# Created on 2013-03-06 by Julien MOREAU aka PixEye

# Last commit of this file (GMT time):
# $Id$
# Local time: $Date$

nbwp=0				# Number of wanted parameters (without options)
cmd=`basename $0`		# Command name
usage="Usage: $cmd [-h]"	# Help message:
usage=$usage"\n\tDisplay this help message.\n"
usage=$usage"\nUsage: $cmd <filename> [...]"
usage=$usage"\n\tSymfony SVN revert."

echo "\ntest"|grep -q ntest && e="-e"	# Does 'echo' need the -e option?

if [ "$#" -lt $nbwp -o "$1" = "-h" ]	# Check parameters number
then echo $e $usage 1>&2 ; exit 2	# Display message help and exit
fi

svn status --ignore-externals lib/*/ |grep ^M |cut -c9- |while read f
do
        echo -n "$f "
        nb_diff_lines=`svn diff "$f"|wc -l`
        echo $e "$nb_diff_lines\t $f"

        if [ "$nb_diff_lines" -lt 14 ]
        then svn revert "$f" || exit $?
        fi
done

exit 0
