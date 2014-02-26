#!/bin/bash

# Par Julien MOREAU aka PixEye
#
# vim: tabstop=8 shiftwidth=8 noet

edit='-e'			# Argument qui lance l'éditeur
last='-l'			# Argument pour afficher LA dernière ligne
stail='-t'			# Argument pour afficher les dernières lignes
search='-s'			# Argument pour chercher une chaîne
notfic=~/.notes			# Nom du fichier qui contient les notes en UTF-8
nom_cmde=`basename $0`		# Nom de la commande

usage="Usage: $nom_cmde [$edit|$stail|$last|$search <pattern>|<phrase>]"
usage=$usage"\n"
usage=$usage"\n\tA note manager script. Options:"
usage=$usage"\n"
usage=$usage"\n\t\t\"$edit\" edit the note file ($notfic)."
usage=$usage"\n\t\t\"$stail\" show the 10 last notes."
usage=$usage"\n\t\t\"$search\" search in the notes."
usage=$usage"\n\t\t\"$last\" show only the last note."

# Pour prendre des notes (une ligne par execution)

if test -z "$EDITOR" ; then EDITOR=vi ; fi

# Option pour aller à la fin du fichier avec vi :
if test "$EDITOR" = vi ; then opt='+' ; else opt="" ; fi

nbl=`cat "$notfic"|wc -l`
if test -z "$LINES" ; then export LINES=24 ; fi
if [ $nbl -lt $LINES ] ; then cmd=cat ; else cmd=less ; fi

if [ "$#" -eq 0 ] ; then
	if [ $nbl -eq 0 ] ; then
		echo "$nom_cmde: you do not have any note." 1>&2
		echo -e $usage 1>&2 ; exit 2
	else
		"$cmd" "$notfic"
		echo -e "*** Use option \"$edit\" to edit\c"
		echo -e " the file with $EDITOR."
	fi
else
	if [ "$#" -eq 1 ] ; then

		# Le "case" ne fonctionne que des constantes...	);
		if test "$1" = "$edit" ; then
			"$EDITOR" $opt "$notfic" ; exit $?
		elif test "$1" = "$stail" ; then
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
