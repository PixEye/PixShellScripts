#!/bin/sh

cmd=`basename $0`
if [ "$1" = '-h' -o "$1" = '--help' ]
then echo "Usage: $cmd <file> [<files...>]" ; exit 1
fi

while [ "$#" -ge 1 ]
do
	f="$1"
	iso_file=`dirname "$f"`"/iso-"`basename "$f"`
	echo -e "Backup of the ISO file : '$iso_file'"

	tmp_file="/tmp/iconv-"`basename "$f"`
	iconv -f 'ISO-8859-15' -t 'UTF-8' "$f" > "$tmp_file"

	mv "$f" "$iso_file"
	mv "$tmp_file" "$f"
	shift
done
