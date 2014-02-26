#!/bin/sh

# cvc.sh
#
# 2004-12-15: Created by Julien MOREAU
# 2012-11-23: Partly translated in English by Julien MOREAU
#
# En: This script only looks for local updates in comparison with a CVS repository
#	& can show a list of editors (with the -e option).
#
# Fr: Ce script regarde simplement si les fichiers sont à jour
#	et éventuellement s'ils sont en cours d'édition (option -e).
#
# Option(s) :
#	-b	Add a blank line at the begining.
#	-e	Show file editors (who use the 'cvs edit ...' command)
#
# Last version under CVS (GMT):
# $Header: /cvs/CVS-tools/cvc.sh,v 1.13 2012-11-23 10:08:38 jmoreau Exp $

nbrp=0	# Number of required parameters

# / Check the command line:
err='false' ; opte='false'
while [ "$#" -ge 1 ]
do
	case "$1" in
		'-b') shift ; echo ;;
		'-e') shift ; opte='true' ;;
		*) shift ; err='true' ;;
	esac
done
if [ "$#" -gt "$nbrp" ] ; then err='true' ; fi

#	Display help if needed:
if "$err" ; then
	cmd=`basename $0`
	echo -e "Usage: $cmd [-b] [-e]" 1>&2
	head -n 19 "$0"|tail -n 6
	exit 1
fi
# \ End of command line checks.

# Start processing:
#	cvs status :
echo "cvs status :"
cvs status 2>&1 \
	| grep -ve 'Status: Up-to-date'$ -e '(none)'$ -e ===== \
		-e 'New file!'$ -e ^'cvs status: Examining ' \
		-e kb$ -e ^"   Repository revision:	" \
	| grep -e ^File -e ^'?' -e '!' \
		-ie err -e abort -e ^'   Sticky ' \
	| nl

#	cvs editors :
if "$opte" ; then
	echo
	echo "cvs editors :"
	#cvs editors|cut -f-4|sed "s/\t/ | /g"
	cvseditors.sh|nl
fi
