#!/bin/sh

cmd=`basename $0`
if [ "$1" = '-h' -o "$1" = '--help' ]
then echo "Usage: $cmd <file> [<files...>]" ; exit 1
fi

while [ "$#" -ge 1 ]
do
	f="$1"
	iso_file=`dirname "$f"`"/.utf8-"`basename "$f"`
	echo -e "Backup of the UTF8 file : '$iso_file'"

	tmp_file="/tmp/iconv-"`basename "$f"`
	iconv -f 'UTF-8' -t 'ISO-8859-15' "$f" > "$tmp_file"

	mv "$f" "$iso_file"
	mv "$tmp_file" "$f"
	shift
done
