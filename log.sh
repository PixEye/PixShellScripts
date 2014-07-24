#!/bin/sh

# 2014-07-17 Created by Julien Moreau aka PixEye

log_file=~/.my-log
now=`date +'%Y-%m-%d %T'` # Example: 2014-07-17 14:46:05

if test -r "$log_file"
then
    last_line=`tail -n1 "$log_file"`
    last_datetime=`echo $last_line|cut -c -19`
    last_date=`echo $last_datetime|cut -d' ' -f1`
    last_time=`echo $last_datetime|cut -d' ' -f2`
    last_h=`echo $last_time|cut -d':' -f1`
    last_m=`echo $last_time|cut -d':' -f2`
    last_s=`echo $last_time|cut -d':' -f3`
    current_h=`date +%k`
    current_m=`date +%M`
    diff_h=`expr $current_h - $last_h`
    diff_m=`expr $current_m - $last_m`

    if [ "$diff_m" -lt 0 ]
    then diff_m=`expr $diff_m + 60` ; diff_h=`expr $diff_h - 1`
    fi

    if [ "$diff_m" -le 9 ] ; then diff_m="0$diff_m" ; fi

    echo "Previous line: $last_line"
    time_diff="$diff_h:$diff_m"
    echo "Difference with previous time: $time_diff"
    set +x  # end of debug mode
fi

new_line="$now $*"
echo "$new_line" >> "$log_file"

echo "Added to '$log_file':"
echo "$new_line"
