#!/bin/sh

# cvseditors.sh
#
# Créé le 22/02/2005 par Julien MOREAU
#
# Dernière version sous CVS (heure GMT) :
# $Header: /cvs/CVS-tools/cvseditors.sh,v 1.4 2012-11-23 10:08:38 jmoreau Exp $
#
# Ce script regarde simplement si les fichiers CVS du répertoire courant
#	sont en cours d'édition (commandes : cvs edit/editors).
#
# Paramètre(s) obligatoire(s) :	néant
# Options :			néant

cvs editors|sed "s/\t/|/g"|while read ligne
do
	export IFS='|'		# séparateur temporaire de colonnes
	set 1 $ligne
	export IFS='	 '	# réinitialisation du séparateur de colonnes

	if [ "$#" -eq 6 ]
	then
		file="$2" ; login="$3" ; date="$4" ; host="$5"
		echo "($date) $login@$host => $file"
	fi
done
