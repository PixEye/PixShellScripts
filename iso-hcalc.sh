#!/bin/bash

# hcalc.sh

# 20030703 Julien MOREAU aka PixEye	Creation

# Horaire vers nombre :
#set 18h05 #
function h2n () {
	# Exemple : 10h30 => 10.5
	param="$1"
	echo $param|grep -qi "h" || param=$param"h00"
	export IFS='hH:'		# s�parateurs possibles entre heures et minutes
	set $param
	export IFS='	 '		# s�parateur par d�faut (espace et tabulation)
	heure="$1"
	minutes="$2"
	#echo $heure"/"$minutes

	# Enl�ve l'�ventuel z�ro non significatif :
	nombre=`echo $heure|sed 's|^0||'`

	if test -n "$minutes"
	then
		##### Attention, pb avec 0<minutes<10 !!! #####
		# Enl�ve l'�ventuel z�ro non significatif :
		minutes=`echo $minutes|sed 's|^0||'`
		#echo -e "minutes=$minutes\n"

		decimale=`echo "100 "'*'" $minutes / 60"|bc \
			|sed -e 's|\.$||'` #-e 's|00*$||'
		if test -n "$decimale" ; then
			if [ "$decimale" -le 9 ] ; then decimale="0$decimale" ; fi
			nombre="$nombre.$decimale"
		fi
	fi

	echo "$nombre"			# le retour de la fonction
	#echo -e "decimale=$decimale\n" ; exit
}

# Nombre vers horaire :
function n2h () {
	# Exemple : 10.5 => 10h30
	param="$1"
	export IFS='.,'			# s�parateurs d�cimaux possibles
	set $param
	export IFS='	 '		# s�parateur par d�faut (espace et tabulation)
	heure="$1" ; decimale="$2"
	echo $heure"/"$decimale

	nbc=`echo -n $decimale|wc -c|sed 's| *||g'`
	while [ $nbc -lt 2 ] ; do decimale=$decimale"0" ; nbc=`expr $nbc + 1` ; done
	minutes=`echo "0.$decimale "'*'" 60"|bc|sed 's|\..*||'`

	echo $heure"h"$minutes	# le retour de la fonction
}

#echo "Test h2n : h2n 10h30 => ["`h2n 10h30`"]" ; exit 0	# test
#echo "Test n2h : n2h 10.5 => ["`n2h 10.5`"]" ; echo		# moins important

nbps=0					# Nombre de param�tres souhait�s (sans option)
cmd=`basename $0`		# Nom de la commande
log=~/tmp/schedule.tsv	# Fichier de log (colonnes s�par�es par des tabulations)
usage="Usage: $cmd -h"		# Message d'aide :
usage=$usage"\n\tAffiche ce message d'aide.\n"

usage=$usage"\nUsage: $cmd disp[lay]|edit"
usage=$usage"\n\tAffiche ou �dite directement le fichier de log."
usage=$usage"\n\tRappel de ce fichier de log : $log\n"

usage=$usage"\nUsage: $cmd [-p]"
usage=$usage"\n\tCalcule la dur�e de travail de la journ�e et l'affiche."
usage=$usage"\n\tL'option -p force � prendre en compte le temps de pause."

echo "\ntest"|grep -q ntest && e="-e"	# echo a-t'il besoin de l'option -e ?

if test "$1" = "-p" ; then pauseOpt=true ; shift ; else pauseOpt=false ; fi

echo "$1"|grep -qE "^disp(lay)?$"
if [ $? -eq 0 ] ; then cat $log ; exit $? ; fi

if test -z "$EDITOR" ; then export EDITOR="vi" ; fi
if test "$1" = "edit" ; then
	if test "$EDITOR" = "vi" -o "$EDITOR" = "vim" -o "$EDITOR" = "gvim"
	then $EDITOR + $log
	else $EDITOR $log
	fi

	exit $?
fi

umask 077
if test ! -r $log ; then touch $log || exit $? ; fi

if [ $# -ne $nbps -o "$1" = "-h" ] ; then	# V�rifie le nb de param�tres
	echo $e $usage 1>&2 ; exit 2			# Affichage aide puis arr�t
fi

# Cr�e ou ajoute le fichier :
tee="" #; if test ! -r $log ; then tee="|tee -a "$log ; fi
echo $e "Date\t\tArriv�e\t\tRepas\tLieu\t\tPause\tD�part\tDur�e"$tee

# Pas cette barre dans le fichier car c'est un TSV (compatibilit�) :
echo -n "---------------+---------------+-------+---------------+"
echo "-------+-------+-----"

# Supprime la derni�re ligne pour la remplacer :
#cp $log $log~ && head -n+1 $log > /tmp/"$cmd.tmp" && mv -f /tmp/"$cmd.tmp" $log

if test -z "$tee" ; then grep h $log|tail -n5 ; fi

export IFS='	'		# juste tabulation
lastLine=`tail -1 $log`
set 1 $lastLine ; shift
if [ "$#" -lt 6 ] ; then exit 0 ; fi

# Exemple de ligne :
# 2003/07/03      10h30           1h30    Santa Romana    0 min   19h30   7.5

date="$1"
harrivee="$2" ; arrivee=`h2n $harrivee`
hrepas="$3" ; repas=`h2n $hrepas`
lieu="$4"
mpause=`echo $5|cut -d' ' -f1`
pause=`h2n "0h$mpause"`
hdepart="$6" ; depart=`h2n $hdepart`
if [ "$#" -ge 7 ] ; then estim="$7" ; fi

export IFS='	 '		# s�parateur par d�faut (espace et tabulation)

form="$depart - $arrivee - $repas"
if $pauseOpt ; then form="$form - $pause" ; fi
count=`echo $form|bc|sed -e 's|00*$||' -e 's|\.$||'`	# Calcul du nb d'heures travaill�es

echo -n $count|grep -q ^[1-9] || exit 0	# R�sultat inf�rieur � z�ro => sortie

#hcount=`n2h $count`			# pas n�cessaire en fait
echo $e "Nombre d'heures travaill�es le $date ($form) : --->\t$count"

#if test -n "$estim" ; then
#		if test ! "$estim" = "$count" ; then
#				echo "Y-aurait'il une erreur... ?"
#		fi
#fi

#nbc=`echo -n $lieu|wc -c|sed 's|  *||g'`
#if [ $nbc -lt 8 ] ; then lieu="$lieu\t" ; fi

# Enregistre dans un fichier :
#echo $e "$date\t$harrivee\t\t$hrepas\t$lieu\t$mpause min\t$hdepart\t$count"\
#	$tee
#echo $e "\t\t[ Enregistr� dans $log ]"

exit 0		# Sortie sans erreur

# vim: textwidth=80 tabstop=4 shiftwidth=4 nowrap
