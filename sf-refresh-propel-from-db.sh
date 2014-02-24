#!/bin/sh

# Refresh symfony1.x auto-generated (by Propel) files.
# Tested with sf1.4 (the PHP framework) under Linux with bash & sed installed.
#
# By Julien Moreau aka PixEye

echo "\ntest"|grep -q ntest && e="-e"   # Does 'echo' need the -e option?

mv -f config/*.xml config/generated-schema.yml /tmp/ 2>> /dev/null

php symfony propel:build-schema || exit $?

src='config/schema.yml'
tmp='config/schema-new.yml'

tooMushStr=', required: true, defaultValue: CURRENT_TIMESTAMP'
sed "s/$tooMushStr//" "$src" > "$tmp" || exit $?
mv -f "$tmp" "$src" || exit $?

sed "s/^\(    is_.*, type:\) TINYINT, size: '1', /\1 BOOLEAN, /" "$src" > "$tmp" || exit $?
mv -f "$tmp" "$src" || exit $?

sed "s/^\(    .*ed: .*, type:\) TINYINT, size: '1', /\1 BOOLEAN, /" "$src" > "$tmp" || exit $?
mv -f "$tmp" "$src" || exit $?

# this is a bit specific to the VPConfig2 project:
sed "s/^\(    about_.*, type:\) TINYINT, size: '1', /\1 BOOLEAN, /" "$src" > "$tmp" || exit $?
mv -f "$tmp" "$src" || exit $?

php symfony propel:build-model || exit $?

php symfony propel:build-forms || exit $?

php symfony propel:build-filters || exit $?

if test -r "data/fixtures/fixtures.yml"
then	echo
	echo 'You may also try:'
	echo $e "\tphp symfony propel:data-load data/fixtures/fixtures.yml"
fi
