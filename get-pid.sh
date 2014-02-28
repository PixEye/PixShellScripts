#!/bin/bash

# 2005-09-30 creation by Julien Moreau (only the 2 echo lines)
# 2014-02-28 improved by Julien Moreau

cmd=`basename "$0"`
echo "\ntest"|grep ntest >> /dev/null && e="-e" # Does echo need the -e option?

if [ "$#" -gt 1 -o "$1" = "-h" -o "$1" = "--help" ]
then echo $e "Usage: $cmd [<process_name>]\n\t Print the process ID." ; exit 1
fi

if [ "$#" -eq 1 ]   # Print PID(s) of the command name passed as arg1:
then ps -o pid= -C "$1" ; exit $?
fi # NB: actually, I prefer to use: ps --forest -flC <process_name>

# man bash:
# (...)
# $$ Expands to the process ID of the shell.
#  In a () subshell, it expands to the process ID of the current shell, not the subshell.
# $! Expands to the process ID of the most recently executed background (asynchronous) command.
# (...)

echo "\$$='$$'"
echo "\$!='$!'"
