#!/bin/bash

# Par Julien MOREAU aka PixEye

edit=edit			# Argument qui lance l'éditeur
display=what			# Argument qui affiche la liste
notfic=~/.psbt			# Nom du fichier qui contient les notes
nom_cmde=`basename $0`		# Nom de la commande
usage="Usage: $nom_cmde [edit|<mots> ...]"		# Message d'aide
usage=$usage"\n\tVous permet d'ajouter une ligne à votre pense-bête."
usage=$usage"\n\tSi le seul parametre est \"$edit\","
usage=$usage"\n\t édite le fichier: $notfic"

# Pour prendre des notes (une ligne par exécution)

tmp="/tmp/$nom_cmde.tmp"
if test `uname -s` != "HP-UX" ; then e="-e" ; fi
if test -z "$EDITOR" ; then EDITOR=vi ; fi

if [ $# -eq 0 ] ; then
	if test ! -s "$notfic" ; then
		echo "$nom_cmde: Votre fichier pense-bête est vide." 1>&2
        	echo $e $usage 1>&2 ; exit 1
	else
		echo $e "*** Utiliser l'argument \"$edit\" pour éditer \c"
		echo $e "directement le fichier avec $EDITOR.\n"
	fi
else
	if [ `echo $1|cut -c-2` = "-h" ] ; then
		echo $e $usage 1>&2 ; exit 2
	elif [ "$1" = $edit ] ; then
		$EDITOR "$notfic"
	elif [ "$1" = "$display" -o "$1" = "quoi" -o "$1" = "koa" ] ; then
		echo
	else
		echo $e "\t. $*" > "$tmp"
		cat "$notfic" >> "$tmp"	# Pour l'ajout en tête
		mv "$tmp" "$notfic"
	fi
	clear
	xhost 2> /dev/null|grep ^"access control enabled" > /dev/null
	if [ $? -eq 0 ] ; then echo $e "x- \c" ; else echo $e "x+ \c" ; fi
	mesg > /dev/null
	if [ $? -eq 1 ] ; then echo $e "m- \c" ; else echo $e "m+ \c" ; fi
	#if mail $e ; then echo $e "You have mail. \c" ; fi
fi

if test ! -s "$notfic" ; then
	echo "$nom_cmde: Votre fichier pense-bête est vide." 1>&2
	echo $e $usage 1>&2 ; exit 1
else
	echo $e "Contenu de votre pense-bête :\n"
	#export LINES=`resize|grep LINE|sed 's|[^0-9]||g'`
	export LINES
	if test -z "$LINES" ; then LINES=24 ; fi
	if test -n "$LINES" ; then
		nbl=`wc -l < "$notfic"`
		nbl2display=`expr $LINES - 5`
		if [ "$nbl" -gt "$nbl2display" ] ; then
			head -n "$nbl2display" "$notfic"
			#echo "(head -n $nbl2display $notfic)"
			echo $e "\t\t\t..."
		else
			cat "$notfic"
		fi
	else
		cat "$notfic"
	fi
	#echo "LINES=$LINES, nbl2display=$nbl2display, nbl=$nbl"
fi

exit 0		# Sortie sans erreur

# vim: tabstop=8 shiftwidth=8 noexpandtab
