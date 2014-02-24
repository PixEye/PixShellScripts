#!/bin/sh

target="fr_FR.utf8"

locale -a|grep ^"$target"$ >> /dev/null ; ret=$?
if [ 0 -ne "$ret" ]
then echo "$target is not available on this system!" ; return 1
fi

cmd=`basename "$0"`
if test "$cmd" = 'utf8.sh'
then echo "To be used like this: . $cmd"
fi

export LC_ALL="fr_FR.utf8" && export LANG="fr_FR.utf8"
