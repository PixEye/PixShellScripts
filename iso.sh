#!/bin/sh

target="fr_FR@euro"

locale -a|grep ^"$target"$ >> /dev/null ; ret=$?
if [ 0 -ne "$ret" ]
then echo "$target is not available on this system!" ; return 1
fi

cmd=`basename "$0"`
if test "$cmd" = 'iso.sh'
then echo "To be used like this: . $cmd"
fi

export LC_ALL="$target" && export LANG="$target"
locale > /tmp/locale.backup || exit $?
export LANG="$target" && export LC_ALL="$target"
