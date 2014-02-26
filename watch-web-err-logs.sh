#!/bin/sh

tail -F \
	/var/log/httpd/*error*log \
	/var/log/apache2/*error*log \
	/var/log/nginx/*error*log
