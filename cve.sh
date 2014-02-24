#!/bin/bash

# cve <file1> [<file2> ...]
#
# Pour éditer un ou plusieurs fichier(s) existant(s) sous CVS.
# - fait un "cvs update" si besoin (status "Needs patch")
# - fait un "cvs edit" pour déclarer aux autres users qu'on édite le fichier
#	(voir la commande "cvs editors")
# - utilise l'éditeur préféré déclaré dans la variable $EDITOR

# (c) 2003-2005 Julien Moreau
# 2002-03 Creation
# 2005-01 Updates
# (c) 2005 VeePee

# Last version under CVS (GMT):
# $Header: /cvs/CVS-tools/cve.sh,v 1.6 2012-11-23 10:08:38 jmoreau Exp $

nbps=1				# Nombre de paramètres souhaités (sans option)
nom_cmde=`basename $0`		# Nom de la commande
usage="Usage: $nom_cmde [-h]"	# Message d'aide
usage=$usage"\n\tAffiche ce message d'aide.\n"
usage=$usage"\nUsage: $nom_cmde <filename> [...]"
usage=$usage"\n\tÉdite des fichiers CVS en posant des verrous d'écriture."

if test `uname` != "HP-UX" ; then e="-e" ; fi	# Compatibilité HP-UX/Linux

if [ $# -lt 0 -o "$1" = "-h" -o "$1" = "--help" ] ; then # Vérif params
	echo $e $usage 1>&2 ; exit 2			 # Aide puis fin
fi

if test -z "$EDITOR" ; then
  if test -z "$USER" ; then export USER=`whoami` ; fi
  echo "$USER"|grep -q moreau
  if [ "$?" -eq 0 ] ; then
    export EDITOR='gvim -geom 128x50'
  else
    if test "$USER" = "gkieffer"
    then export EDITOR=emacs
    else export EDITOR=vi
    fi
  fi
fi

while [ "$#" -ge 1 ]
do
  file="$1"

  lstatus=`cvs status "$file"|grep ^'File:'`
  status=`echo "$lstatus"|sed 's|.*Status: ||'`
  if test -n "$lstatus" ; then echo "$lstatus" ; fi
  case "$status" in
	'Up-to-date') ;;
	'Locally Modified') ;;
	'Locally Added') ;;
  	'Needs Patch') cvs update ;;
  	'Needs Checkout') cvs update "$file" ;;
	*) exit 3 ;;
  esac

  editors=`cvs editors "$file"|cut -f-4`
  nb_editors=`echo $editors|grep -v ^$|wc -l`

  if [ $nb_editors -eq 0 ] ; then
    cvs edit "$file" && $EDITOR "$file"
  else
    ki=""
    if [ "$nb_editors" -eq 1 ] ; then ki=`cvs editors "$file"|cut -f2` ; fi
    if test "$ki" = `whoami` ; then
      echo "Vous êtes déjà éditeur de ce fichier."
      sleep 2
      $EDITOR "$file"
    else
      echo -e "Il y a déjà $nb_editors éditeur(s) de $file !\n$editors"
    fi
  fi

  shift
done
