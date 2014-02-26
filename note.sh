#!/bin/bash

# Par Julien MOREAU aka PixEye

edit='-e'			# Argument qui lance l'éditeur
last='-l'			# Argument pour afficher LA dernière ligne
tail='-t'			# Argument pour afficher les dernières lignes
search='-s'			# Argument pour chercher une chaîne
locale|grep ^'LC_MESSAGES='|grep -i utf >> /dev/null
if [ "$?" -eq 0 ]
then notfic=~/.notes-utf8	# Nom du fichier qui contient les notes en UTF-8
else notfic=~/.notes-iso	# Nom du fichier qui contient les notes en ISO-8859
fi
nom_cmde=`basename $0`		# Nom de la commande
usage="Usage: $nom_cmde [$edit|$tail|$last|$search <pattern>|<phrase>]"
usage=$usage"\n\tVous permet de prendre des notes."
usage=$usage"\n\tL'option \"$edit\" permet de modifier le fichier $notfic\n\t"
usage=$usage"L'option \"$tail\" permet de ne lister que la fin de ce fichier.\n"
usage=$usage"\tL'option \"$search\" permet de chercher dans ce fichier.\n"
usage=$usage"\tL'option \"$last\" permet de n'en lister que la derniere ligne."

# Pour prendre des notes (une ligne par execution)

if test -z "$EDITOR" ; then EDITOR=vi ; fi

# Option pour aller à la fin du fichier avec vi :
if test "$EDITOR" = vi ; then opt='+' ; else opt="" ; fi

nbl=`cat "$notfic"|wc -l`
if test -z "$LINES" ; then export LINES=24 ; fi
if [ $nbl -lt $LINES ] ; then cmd=cat ; else cmd=less ; fi

if [ "$#" -eq 0 ] ; then
	if [ $nbl -eq 0 ] ; then
		echo "$nom_cmde: Votre fichier de notes est vide." 1>&2
        	echo -e $usage 1>&2 ; exit 2
	else
		"$cmd" "$notfic"
		echo -e "*** Utilisez l'argument \"$edit\" pour éditer\c"
		echo -e " directement le fichier avec $EDITOR."
	fi
else
	if [ "$#" -eq 1 ] ; then

		# Le "case" ne fonctionne que des constantes...	);
		if test "$1" = "$edit" ; then
			"$EDITOR" $opt "$notfic" ; exit $?
		elif test "$1" = "$tail" ; then
			tail "$notfic" ; exit $?
		elif test "$1" = "$last" ; then
			tail -n1 "$notfic" ; exit $?
		elif test `echo $1|cut -c-2` = "-h" ; then
			echo -e $usage 1>&2 ; exit 2
		else
			echo "Added to your note pad (\"$notfic\"):"
			echo $* | tee -a $notfic
		fi
	else
		if test "$1" = "$search" ; then
			shift
			type ack-grep >> /dev/null
			if [ $? -eq 0 ]
			then ack-grep -i "$*" "$notfic"
			else grep -i "$*" "$notfic"
			fi
			exit $?
		else
			echo "Added to your note pad (\"$notfic\"):"
			echo $* | tee -a $notfic
		fi
	fi
fi

exit 0		# Sortie sans erreur

