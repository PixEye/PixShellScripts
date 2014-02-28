#!/bin/sh

# usage.sh (french version)

# Created in 1998 by Julien MOREAU aka PixEye

# Last commit of this file (GMT) :
# $Id$
# Local time: $Date$

nbps=2				# Nombre de paramètres souhaités (sans option)
cmd=`basename $0`		# Nom de la commande
usage="Usage: $cmd [-h|--help]"	# Message d'aide
usage=$usage"\n\tAffiche ce message d'aide.\n"
usage=$usage"\nUsage: $cmd <filename> [<param2> ...]"
usage=$usage"\n\tVérifie le nombre de paramètres."
usage=$usage"\n\tSi celui-ci est erroné, affiche un message d'aide."
usage=$usage"\n\n\tCe script n'est en fait que le début d'autres scripts.\n"
#usage=$usage"\n\t."

echo "\ntest"|grep ntest >> /dev/null && e="-e"	# besoin option -e pour echo ?

if [ "$#" -ne "$nbps" -o "$1" = "-h" -o "$1" = "--help" ] # Vérifie le nb de paramètres
then echo $e $usage 1>&2 ; exit 2		# Affichage aide puis arrêt
fi

if test ! -r "$1"	# Si le 1er arg n'est pas un fichier lisible
then echo $e "Fichier \"$1\" illisible ou inexistant !" 1>&2 ; exit 3
fi

# METTRE LE CODE PRINCIPAL ICI

exit 0		# Sortie sans erreur

# Line for vim editing:
# vim: tabstop=8 shiftwidth=8 textwidth=80 noexpandtab
