#!/bin/sh

# Hosts search by Julien MOREAU aka PixEye

type ack-grep >> /dev/null 2>&1 && grep="ack-grep" || grep="grep -n --color=auto"
$grep $* /etc/hosts
