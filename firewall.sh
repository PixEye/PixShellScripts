#!/bin/sh

#
# Script de configuration d'une seule machine avec ipchains ou iptables
#
# 20011129 création	Julien MOREAU aka PixEye
#

if test "$1" = "-t" ; then
	shift
	DEBUG=true ; i=0 ; echo 	# DEBUG mode
fi

# $if_pub correspond à l'interface réseau extérieure (vers Internet)
if_pub="ppp0"			# Interface publique

#fwcmd=/sbin/ipchains		# Commande de filtrage (ancienne version)
fwcmd=/sbin/iptables	# Commande de filtrage (nouvelle version)

#
# Quelle est votre machine ?
#  (certains serveurs ne tournent que sur certaines machines)
#
host=`hostname -s`
if test -z "$host" ; then
	echo "Impossible de trouver le nom de votre machine !" 1>&2
	exit 1
fi

###############################
# Début des traitements :
#
cmd=`basename $0`
ipcmd=`basename $fwcmd`
case $ipcmd in
	ipchains) input=input ; output=output ; forward=forward ; deny=DENY
		if="-i" ; sp="" ; dp="" ;;
	iptables) input=INPUT ; output=OUTPUT ; forward=FORWARD ; deny=DROP
		if="-o" ; sp="--sport" ; dp="--dport" ;;
	*) echo "$cmd: Commande $ipcmd non supportée !" 1>&2 ; exit 2
esac

fw_if="$input"
lo="localhost"

# Obtention de l'IP de l'interface publique :
#  Merci de ne pas changer les regexp (testé sur 4 machines différentes :
#   une Suse 7.0, une Suse 7.3, une Debian et un serveur HP/UX)
ip_pub=`ifconfig $if_pub|grep "inet "|sed -e 's|^.*inet [^0-9]*||' -e 's| .*$||'`
if [ $DEBUG ] ; then echo "Public IP (on $if_pub): $ip_pub" ; fi
if test -z "$ip_pub" ; then echo "Cannot find your public IP!" ; exit 3 ; fi

# Vérifie la syntaxe de la ligne de commande :
case "$1" in
	status)		$fwcmd -L ; exit $? ;;
	stat)		$fwcmd -nL ; exit $? ;;
	stop)		echo -n "Stoping" ;;
	start)		echo -n "Starting" ;;
	restart)	echo -n "Restarting" ;;
	*) echo "Usage: $cmd [-t] (start|stop|restart|stat|status)" ; exit 4 ;;
esac

echo -n " the $ipcmd firewall on $host ... "
if [ $DEBUG ] ; then echo ; fi

# Réinitialisation : ----------------------------------------------------------
$fwcmd -F $input	|| exit $?
$fwcmd -F $forward	|| exit $?
$fwcmd -F $output	|| exit $?

# Police en vigueur par défaut :
$fwcmd -P $input ACCEPT	 || exit $?
$fwcmd -P $forward $deny || exit $?
$fwcmd -P $output ACCEPT || exit $?

if test "$1" = stop ; then echo "STOPPED!" ; exit 0 ; fi

# Toutes les commandescommencent avec :
filter="$fwcmd -A $fw_if -i $if_pub -d $ip_pub -s 0/0"

# Les ports que l'on autorise (serveurs sur la machine locale) : --------------
#  (on précise le port destination ici)
# - ICMP (ping) :
$filter -p icmp -j ACCEPT || exit $?
# - telnet (port 23) :
#$filter -p tcp $dp telnet -j ACCEPT||exit $?
# - ssh (port 22) :
$filter -p tcp $dp ssh -j ACCEPT || exit $?
# - SMTP (mail, port 25) :
#$filter -p tcp $dp smtp -j ACCEPT || exit $?
# - HTTP (web, port 80) :
$filter -p tcp $dp www -j ACCEPT || exit $?
# - auth (port 113, en TCP) :
#$filter -p tcp $dp auth -j ACCEPT || exit $?
# - Serveur X (port 6000 pour les export DISPLAY) :
#$filter -p tcp -s 62.160.249.0/24 $dp 6000 -j ACCEPT
# - DNS (port 53, en TCP et UDP) :
if test "$host" = nessie -o "$host" = raptor ; then
$filter -p tcp $dp domain -j ACCEPT || exit $?
$filter -p udp $dp domain -j ACCEPT || exit $?
fi

# On autorise à recevoir les réponse sur certains ports (nos clients) : -------
#  (on précise le port source ici)
$filter -p tcp $sp ssh -j ACCEPT || exit $?
$filter -p tcp $sp smtp -j ACCEPT || exit $?
$filter -p tcp $sp www -j ACCEPT || exit $?
$filter -p tcp $sp https -j ACCEPT || exit $?
#$filter -p tcp -s imprimosaurus $sp printer -j ACCEPT
$filter -p tcp $sp pop3 -j ACCEPT || exit $?
$filter -p tcp $sp ftp -j ACCEPT || exit $?
$filter -p tcp $sp ftp-data -j ACCEPT||exit $?
$filter -p tcp $sp nntp -j ACCEPT || exit $?
$filter -p tcp $sp whois -j ACCEPT || exit $?
$filter -p tcp $sp finger -j ACCEPT || exit $?
$filter -p udp $sp sunrpc -j ACCEPT || exit $?
$filter -p tcp $sp sunrpc -j ACCEPT || exit $?
$filter -p udp $sp talk -j ACCEPT || exit $?
$filter -p tcp $sp mysql -j ACCEPT || exit $?
$filter -p udp $sp mysql -j ACCEPT || exit $?
$filter -p tcp $sp printer -j ACCEPT||exit $?
$filter -p tcp $sp imap -j ACCEPT || exit $?
$filter -p tcp $sp auth -j ACCEPT || exit $?
$filter -p udp $sp domain -j ACCEPT || exit $?
$filter -p tcp $sp domain -j ACCEPT || exit $?
$filter -p tcp $sp ntp $dp ntp -j ACCEPT
$filter -p udp $sp ntp $dp ntp -j ACCEPT
# Le port 389 correspond à LDAP :
$filter -p udp $sp 389 -j ACCEPT || exit $?
# Le port 1080 correspond à socks :
$filter -p tcp $sp 1080 -j ACCEPT || exit $?
# Le port 2401 correspond à CVS :
$filter -p tcp $sp 2401 -j ACCEPT || exit $?
# Le port 3128 correspond à squid :
$filter -p tcp $sp 3128 -j ACCEPT || exit $?
# Le port 5900 correspond à VNC :
$filter -p tcp $sp 5900 -j ACCEPT || exit $?
# Le port 6667 correspond à IRC :
$filter -p tcp $sp 6667 -j ACCEPT || exit $?

# On rejette tous les autres ports (sur $if_pub) : ----------------------------
if [ "$ipcmd" = iptables ] ; then
  $filter -j LOG --log-prefix "REJECTED packet:"
  $filter -j REJECT || exit $?
else	 # ipchains:
  $filter -l -j REJECT || exit $?
fi

echo "OK."
exit 0
