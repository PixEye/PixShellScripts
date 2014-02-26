#!/bin/bash

# By Julien MOREAU aka PixEye

nbwp=2			# Number of wanted parameters
cmd=${0##*/}		# Command name
usage="Usage: $cmd <ext1> <ext2>"	# Help message
usage=$usage"\n\tChange the extension of all files from the current directory"
usage=$usage"\n\t ending with \".<ext1>\" with new extension <ext2>."
usage=$usage"\n\tReturn the number of renamed files."

if test `uname` != "HP-UX" ; then e="-e" ; fi # shall we use the -e option for echo?

if [ $# -ne $nbwp ]	# If there is NOT the right number of parameters,
then echo $e $usage 1>&2 ; exit 2	# Display the help message & stop.
fi

n=0
for fic in *.$1
do
	new="`echo $fic|sed -e 's/^\(.*\)\.[^\.]*$/\1/'`.$2"
	echo $e "$fic -> $new"
	mv -i -- "$fic" "$new"
	n=`expr $n + 1`
done

exit $n		# Number of changed filenames
