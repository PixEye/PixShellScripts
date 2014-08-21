#!/bin/sh

# Original script in "Fetching new commits" chapter of:
# http://simonecarletti.com/blog/2009/07/configuring-git-repository-with-redmine/
#
# 2014-08-19 adapted by J. Moreau aka PixEye

repo_dir=~/git-chechouts
cd "$repo_dir" || exit $?

for d in *
do
	cd "$repo_dir/$d" || continue
	git pull origin master || continue
	cd /opt/WebSites/redmine || continue
	# /usr/bin/ruby1.8 script/runner "Repository.fetch_changesets" -e production
	/usr/bin/ruby script/runner "Repository.fetch_changesets" -e production
done
