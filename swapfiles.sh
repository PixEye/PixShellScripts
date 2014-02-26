#!/bin/bash

# swapfiles

# 20010814 Julien MOREAU aka PixEye	Cr�ation

nbps=2				# Nombre de param�tres souhait�s (sans option)
nom_cmde=`basename $0`		# Nom de la commande
usage="Usage: $nom_cmde [-h]"	# Message d'aide
usage=$usage"\n\tAffiche ce message d'aide.\n"
usage=$usage"\nUsage: $nom_cmde <file1> <file2>"
usage=$usage"\n\t�change les noms de 2 fichiers."

if [ $# -ne $nbps -o "$1" = "-h" ] ; then	# V�rifie le nb de param�tres
	echo -e $usage 1>&2 ; exit 2		# Affichage aide puis arr�t
fi

if test ! -r "$1" ; then	# Si le 1er arg n'est pas un fichier lisible
	echo -e "Fichier \"$1\" illisible ou inexistant !" 1>&2 ; exit 3
fi

if test ! -r "$2" ; then	# Si le 1er arg n'est pas un fichier lisible
	echo -e "Fichier \"$2\" illisible ou inexistant !" 1>&2 ; exit 3
fi

tmp=`tempfile`
mv "$1" "$tmp" && mv "$2" "$1" && mv "$tmp" "$2"
