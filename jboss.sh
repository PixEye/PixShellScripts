#!/bin/sh

# /etc/init.d/jboss     (start|stop|status script)
#
# 2013-03-28 created by JMoreau

cmd=`basename $0`       # short command name
dir='/opt/jboss/bin'    # binary directory
start="$dir/run.sh"     # start program
stop="$dir/shutdown.sh" # stop  program
log="/var/log/$cmd.log" # current log filename

case "$1" in
  'status') ps -fC java |grep jboss >> /dev/null
    if [ $? -eq 0 ]
    then echo "$cmd is running at: `date`."     ; exit 0
    else echo "$cmd is NOT running at: `date`." ; exit 1
    fi ;;

  'start') "$0" status && exit 1 # avoid starting several instance
    if test `whoami` != 'root'
    then echo "You should be root to do this!" 2>&1 ; exit 2
    fi
    "$start" -b 0.0.0.0 > "$log" &  # start command
    sleep 1
    "$0" status
    exit $? ;;

  'restart') "$0" stop && "$0" start ; exit $? ;;

  'rotate'|'rotatelogs') "$0" stop
    sleep 60
    "$0" status && exit 1 # check if it's well stopped

    dow=`date +%u`
    last_log="/var/log/$cmd-$dow.log" # stamped log filename
    mv -f "$log" "$last_log"
    rm -f "$new_log.gz" 2>> /dev/null
    gzip "$last_log"

    "$0" start ; exit $? ;;

  'stop') "$0" status || exit 0 # test if already stopped
    if test `whoami` != 'root'
    then echo "You should be root to do this!" 2>&1 ; exit 2
    fi
    "$stop" --shutdown  # stop command
    ret=$?
    if [ 0 -eq $ret ]
    then echo "$cmd stopped at: `date`"
    fi
    exit $ret ;;

  *) echo "Invalid argument: '$1'!" ; exit 1 ;;
esac

exit 0
