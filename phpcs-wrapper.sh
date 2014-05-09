#!/bin/sh

# A PhpCodeSniffer wrapper

files=$*

for f in $files
do php -n -l -f "$f" || exit $?
done |grep -v ^'No syntax errors detected in '

# phpcs $files |grep -ve ^$ -e '---'  # returns 1 even if all right :-/

output="/tmp/phpcs.out"
phpcs $files > "$output" 2>&1
ret=$?
grep -ve ^$ -e '---' "$output"
rm "$output"

exit $ret
