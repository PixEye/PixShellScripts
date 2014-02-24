#!/bin/sh

# sf-svn-revert.sh

# Created on 2013-03-06 by Julien MOREAU aka PixEye

# Last commit (GMT time) :
# $Id$
# Local time: $Date$

nbwp=0				# Number of wanted parameters (without options)
cmd=`basename $0`		# Command name
usage="Usage: $cmd [-h]"	# Help message:
usage=$usage"\n\tDisplay this help message.\n"
usage=$usage"\nUsage: $cmd <filename> [...]"
#usage=$usage"\n\tCheck parameters number."
#usage=$usage"\n\tIf it is not correct, then display an help message."
#usage=$usage"\n\n\tThis is just the begining of any quite good shell script.\n"
usage=$usage"\n\tSymfony SVN revert."

echo "\ntest"|grep -q ntest && e="-e"	# Does 'echo' need the -e option?

if [ "$#" -lt $nbwp -o "$1" = "-h" ]	# Check parameters number
then echo $e $usage 1>&2 ; exit 2	# Display message help and exit
fi

svn status --ignore-externals lib/*/ |grep ^M |cut -c9- |while read f
do
        echo -n "$f "
        nb_diff_lines=`svn diff "$f"|wc -l`
        echo $nb_diff_lines

        if [ "$nb_diff_lines" -lt 14 ]
        then svn revert "$f" || exit $?
        fi
done

exit 0
