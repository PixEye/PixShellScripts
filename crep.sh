#!/bin/sh

# A color grep without ack-grep

# 2010-08-26 created by: Julien MOREAU aka PixEye
#grep --color=always -nR $* |grep -ve svn -e swp -e CVS

# 2011-05-30a version:
#grep --color=always -nrH $* |grep -ve svn -e swp -e CVS

# 2011-05-30b version:
grep --color=always --exclude-dir='.git' --exclude-dir='.svn' --exclude-dir='CVS' \
	--exclude='.DS_Store' --exclude='*.swp' --exclude='*.pyc' -nr $*
