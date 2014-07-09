#!/bin/sh

# Created on 2011-08-11 by Julien MOREAU aka PixEye

cmd=`basename "$0"`
echo "\ntest"|grep ntest >> /dev/null && e="-e"   # is the "-e" echo option needed?

if [ "$#" -ne 2 ]
then echo "Usage: $cmd <dir1> <dir2>" ; return 2
fi

min_diff=999999 # big value
less_diff_entry=''
dir1="$1" ; dir2="$2"
tmp_file="/tmp/$cmd"

if [ ! -d "$dir1" ]
then echo "'$dir1' is not a directory!" ; return 3
fi
if [ ! -d "$dir2" ]
then echo "'$dir2' is not a directory!" ; return 4
fi

echo $e "Going to: \c" # the "cd" bellow is verbose on my linux box
cd "$dir1" || return $?

ls -d */ |while read f
do
    n=`diff -r "$f" "../$dir2/$f"|wc -l`
    echo "Debug: $n diff between '$f' & '../$dir2/$f'." # can be commented
    if [ $n -lt $min_diff ]
#   if [ $n -gt 0 -a $n -lt $min_diff ]
    then min_diff=$n ; less_diff_entry="$f"
	 # a temporary file is needed to keep memory from the while namespace:
	 echo $less_diff_entry > "$tmp_file"
#	 echo "Debug: min_diff=$min_diff ; less_diff_entry='$f'" # can be commented
    fi
done

if test -r "$tmp_file"
then
	echo $e "Less diff entry is: \c"
	cat "$tmp_file"
	rm "$tmp_file"
else
	echo "Did not find any difference!"
	return 1
fi
