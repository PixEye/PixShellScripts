#!/bin/sh

# Created on 2014-02-14 by Julien Moreau

# See: https://github.com/squizlabs/PHP_CodeSniffer
# See: http://pear.php.net/package/PHP_CodeSniffer/docs
# See: http://pear.php.net/manual/en/package.php.php-codesniffer.advanced-usage.php

echo "\ntest"|grep -q ntest && e="-e"   # Does 'echo' need the -e option?

if test `whoami` != 'root'
then echo $e "You should run this as root (with sudo for example)." 1>&2 ; exit 1
fi

set -x	# verbose mode

# Hide warnings
phpcs --config-set show_warnings 0 || exit $?

# Let say a tab is equivalent to 4 spaces
### phpcs --config-set tab_width 4 || exit $?

phpcs --config-show
# Array
# (
#     [show_warnings] => 0
#     [tab_width] => 4
# )

# To reset the config, you may use:
# $ sudo phpcs --config-delete <option>
