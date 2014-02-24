#!/bin/sh

# cvseditors.sh
#
# Cr�� le 22/02/2005 par Julien MOREAU
#
# Derni�re version sous CVS (heure GMT) :
# $Header: /cvs/CVS-tools/cvseditors.sh,v 1.4 2012-11-23 10:08:38 jmoreau Exp $
#
# Ce script regarde simplement si les fichiers CVS du r�pertoire courant
#	sont en cours d'�dition (commandes : cvs edit/editors).
#
# Param�tre(s) obligatoire(s) :	n�ant
# Options :			n�ant

cvs editors|sed "s/\t/|/g"|while read ligne
do
	export IFS='|'		# s�parateur temporaire de colonnes
	set 1 $ligne
	export IFS='	 '	# r�initialisation du s�parateur de colonnes

	if [ "$#" -eq 6 ]
	then
		file="$2" ; login="$3" ; date="$4" ; host="$5"
		echo "($date) $login@$host => $file"
	fi
done
