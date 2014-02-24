#!/bin/bash

# swapfiles

# 20010814 Julien MOREAU aka PixEye	Création

nbps=2				# Nombre de paramètres souhaités (sans option)
nom_cmde=`basename $0`		# Nom de la commande
usage="Usage: $nom_cmde [-h]"	# Message d'aide
usage=$usage"\n\tAffiche ce message d'aide.\n"
usage=$usage"\nUsage: $nom_cmde <file1> <file2>"
usage=$usage"\n\tÉchange les noms de 2 fichiers."

if [ $# -ne $nbps -o "$1" = "-h" ] ; then	# Vérifie le nb de paramètres
	echo -e $usage 1>&2 ; exit 2		# Affichage aide puis arrêt
fi

if test ! -r "$1" ; then	# Si le 1er arg n'est pas un fichier lisible
	echo -e "Fichier \"$1\" illisible ou inexistant !" 1>&2 ; exit 3
fi

if test ! -r "$2" ; then	# Si le 1er arg n'est pas un fichier lisible
	echo -e "Fichier \"$2\" illisible ou inexistant !" 1>&2 ; exit 3
fi

tmp=`tempfile`
mv "$1" "$tmp" && mv "$2" "$1" && mv "$tmp" "$2"
