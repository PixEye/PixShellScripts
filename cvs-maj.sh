#!/bin/sh

# cvs-maj.sh
#
# Ce script fait une synchronisation entre le répertoire local et celui sous CVS
#
# Paramètre : le commentaire du commit global
#
# Créé le 14/12/2004 par Julien MOREAU
#
# Dernière version sous CVS :			(heure GMT)
# $Header: /cvs/CVS-tools/cvs-maj.sh,v 1.5 2012-11-23 10:08:38 jmoreau Exp $

commande="$0"		# Nom complet de la commande (avec chemin)
cmd=`basename $0`	# Nom de ce fichier (sans chemin)
comment="$*"		# Commentaire pour le commit global
cwd='.'				# Current Way Directory (répertoire parcouru par CVS status)

# Fichier contenant la liste des fichiers à ajouter dans CVS :
files2add=~/tmp/CVSfiles2add.tmp	# sert également de fichier verrou

mkdir -p ~/tmp		# Crée un répertoire temporaire perso s'il n'existe pas déjà
if test -f "$files2add" ; then
	echo -e "\nLe fichier verrou : \"$files2add\" existe déjà !\n" 1>&2
	echo -e "Un autre $cmd est peut être en cours d'exécution." 1>&2
	echo -e "Si vous pensez que ce n'est pas le cas,\c" 1>&2
	echo -e " effacez ce fichier temporaire\n puis relancez $cmd" 1>&2
	exit 1
fi
> "$files2add"		# Remise à zéro de la liste des fichiers à ajouter

echo "cvs status (pour savoir s'il y a des conflits ou des fichiers à ajouter)"
cvs status 2>&1 | grep -v ^$ | sed 's/^[        ]*//' | while read ligne
do
	# Trouve le titre de la ligne (20 car max) :
	titreLigne=`echo $ligne|cut -d':' -f1|cut -c-20`

	# Extrait la suite de la ligne (tout sauf le titre) :
	suiteLigne=`echo $ligne|cut -d':' -f2-`

	# Test si "(none)" est présent ou si une version est bloquée :
	echo "$ligne"|grep -q '(none)'
	nonePresent=$?

	case "$titreLigne" in
		"cvs server") mot1=`echo $suiteLigne|cut -d' ' -f1`
			if test "$mot1" = "Examining" ; then
				# Obtention du répertoire étudié :
				cwd="`echo $suiteLigne|cut -d' ' -f2-`"
			else
				echo "Erreur CVS non reconnue :" 1>&2
				echo $ligne 1>&2
				exit 2
			fi ;;
		"====================") ;;
		"File") # Met les mots de la suite de la ligne dans $1 $2 ... :
			set 1 $suiteLigne ; shift

			# Obtention du nom de fichier :
			if test "$1 $2" = "no file" ; then shift 2 ; fi
			fichier="$1" ; shift
			while test ! "$1" = "Status:" ; do
				fichier="$fichier $1" ; shift
			done

			# Obtention du statut CVS du fichier :
			shift ; status="$*"
			case "$status" in
				"Up-to-date") ;;
				"Locally Modified") ;;
				"Needs Checkout") ;;
				*)	echo -e "\nStatus non reconnu et/ou non conforme :"
					echo -e "$status\tpour le fichier : $fichier"
				;;
			esac

			# Affichage de la progression (fichier par fichier) :
			#echo -e "$status\t$fichier"
			echo -e ".\c"
			;;
		"Working revision") ;;
		"Repository revision") ;;
		"Sticky Tag"|"Sticky Date"|"Sticky Options")
			if [ $nonePresent -eq 1 ] ; then
				echo -e "\n$cmd warning: $cwd/$fichier -> $ligne"
			fi ;;
		*)	mot1=`echo $titreLigne|cut -d' ' -f1`
			if test "$mot1" = '?' ; then
				set 1 $ligne ; shift 2
				file2add="$*"
				# Si c'est un répertoire, il faut aussi ajouter les fichiers
				# qu'il y a dedans :
				if test -d "$file2add" ; then
					echo -e "Nouveau répertoire à ajouter : \"$file2add\""
					find "$file2add"|while read f
					do
						echo "$f" >> "$files2add"
					done
				else
					echo -e "Nouveau fichier à ajouter : \"$file2add\""
					echo "$file2add" >> "$files2add"
				fi
			else
				echo -e "\nLigne non reconnue :\n$ligne" 1>&2
				echo -e "Titre : $titreLigne" 1>&2
				exit 3
			fi ;;
	esac
done

# Liste des fichiers à ajouter :
if test -s "$files2add" ; then
	echo -e "\nListe des fichiers à ajouter :"
	cat "$files2add"
	set 1 `cat "$files2add"` ; shift
	liste2add="$*"

	# Le cvs add :
	echo -e "cvs add $liste2add"
	cvs add $liste2add || exit $?
else
	echo "Aucun fichier à ajouter dans CVS."
fi
rm -f "$files2add"

echo
if test -z "$comment" ; then
	echo "Vous devez préciser un commentaire en paramètre !" 1>&2
	exit 4
fi

# Le cvs commit :
echo "cvs commit -m \"$comment\""
cvs commit -m "$comment" || exit $?

# Le cvs update :
echo "cvs update (pour récupérer les éventuels nouveaux fichiers)"
cvs update

# Pour l'édition sous vim :
# vim: noexpandtab tabstop=4 shiftwidth=4
