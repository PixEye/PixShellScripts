#!/bin/bash

# Fixed and adapted from:
# http://stoilis.wordpress.com/2010/06/18/automatically-remove-old-kernels-from-debian-based-distributions/
# by Julien Moreau AKA PixEye.

# Text color variables
bold=$(tput bold)
rst=$(tput sgr0)	# Reset
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
# options:
underline=$(tput sgr 0 1)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)

cd /boot || exit $?
INSTALLED_KERNELS=`ls -1 vm*`
NUMBER_OF_INSTALLED_KERNELS=`echo $INSTALLED_KERNELS |wc -w`
LAST_INSTALLED_KERNEL=`ls -1 vm* |tail -1`
CURRENT_VERSION=`uname -r`
RUNNING_KERNEL=`ls vm*$CURRENT_VERSION`
if test "$RUNNING_KERNEL" = "$LAST_INSTALLED_KERNEL"
then addon='' ; else addon=$red
fi

echo -e "${bold}Current kernel is.......: $addon$RUNNING_KERNEL$rst"

echo "/ Installed kernels:"
echo "$INSTALLED_KERNELS"|nl
echo "\ -> $NUMBER_OF_INSTALLED_KERNELS kernels installed."

if test "$RUNNING_KERNEL" = "$LAST_INSTALLED_KERNEL"
then addon='' ; else addon=$green
fi
echo -e "${bold}Last installed kernel is: $addon$LAST_INSTALLED_KERNEL$rst"

i=1
KERNELS_TO_REMOVE=''
for k in $INSTALLED_KERNELS
do
	k="`echo $k |cut -d'-' -f2-`"
	# echo "k='$k'"	# for debug

	if [ "vmlinuz-$k" == "$RUNNING_KERNEL" ]
	then continue
	# else echo "$k != $RUNNING_KERNEL"	# for debug
	fi

	i=`expr $i + 1`
	if [ $i -ge $NUMBER_OF_INSTALLED_KERNELS ] ; then continue ; fi	# keep a backup kernel

	k="`echo $k |awk -F- '{print $1"-"$2}'`"
	if [ "$KERNELS_TO_REMOVE" == '' ]
	then KERNELS_TO_REMOVE="$k"
	else KERNELS_TO_REMOVE="$KERNELS_TO_REMOVE|$k"
	fi
done

if test "$RUNNING_KERNEL" != "$LAST_INSTALLED_KERNEL"
then echo "$bold${yellow}You need to reboot with the last installed kernel.$rst"
fi

if [ "$KERNELS_TO_REMOVE" == '' ]
then echo -e "$bold${green}There is no kernel to remove.$rst" ; exit 1
fi

echo -e "$bold${yellow}Kernels to remove: ${KERNELS_TO_REMOVE}.$rst"

#if test "$RUNNING_KERNEL" != "$LAST_INSTALLED_KERNEL"
#then
#	echo "$bold${red}Firstly, you need to reboot with the last installed kernel please!$rst"
#	exit 1
#fi

if test `whoami` != 'root'
then echo -e "$bold${red}I need root privileges in order to clean!$rst" ; exit 2
fi

# set -x # Set verbose mode
apt-get remove --purge `dpkg -l |awk '{print $2}' |egrep "$KERNELS_TO_REMOVE"`
