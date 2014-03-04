#!/bin/bash

# Adapted from: http://www.freesource.info/wiki/DmitriyKruglikov/Raznoe/AD2LDAP
#  by: Julien MOREAU aka PixEye
#  on the: 2009-02-23

nbps=2				# Number of wanted parameters (without option)
cmd=`basename $0`		# Name of the command
usage="Usage: $cmd [-h|--help]\n\t"	# Help message
usage=$usage"Display this help message.\n\n"
usage=$usage"Usage: $cmd [-a <access_node>] [-b <base>] [-d <bind_dn>] <hostname> <filename>\n\t"
usage=$usage"Inject the content of AD format file <filename.ldif>\n\t\t"
usage=$usage"to the server <hostname>.\n\t"
usage=$usage"Default access_node is: CN=Users_Veepee"

echo "\ntest"|grep -q ntest && e="-e"	# Does echo need the -e option?
base=''
bind_dn=''
access_node=''

# See: http://stackoverflow.com/questions/16483119/example-of-how-to-use-getopt-in-bash
TEMP=`getopt -o a:b:d:h --long help -n '$cmd' -- "$@"`
# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true
do
    case "$1" in
        -a) access_node=$2 ; shift 2 ;;
        -b) base=$2 ; shift 2 ;;
        -d) bind_dn=$2  ; shift 2 ;;
        --) shift ; break ;;
        *) echo $e $usage 1>&2; exit 2 ;;	# Display help message and stop
    esac
done

if [ "$#" -ne "$nbps" ] # Check parameters number
then echo $e $usage 1>&2; exit 2		# Display help message and stop
fi

host="$1"
input_file="$2"
if [ ! -r "$input_file" ]	# Is the file argument exist and is readable?
then echo $e "File \"$2\" is not readable!\n" 1>&2; echo $e $usage 1>&2; exit 3
fi

umask 077 # Protect temporary files from being accessed by other users of the system

if [ -z "$base" ]; then base="dc=$host,dc=vp"; fi
if [ -z "$bind_dn" ]; then bind_dn="cn=admin,$base"; fi
if [ -z "$access_node" ]; then access_node='CN=Users_Veepee'; fi

tmp_file='/tmp/'`basename "$input_file"`
echo "Temporary file is: $tmp_file"
echo $e -n 'Please enter the password: '
read bindpw

init_val="objectClass: inetOrgPerson\n"
init_val=$init_val"objectClass: OXUserObject"
access_string="$access_node,"
nbpadded=0	# Number of persons added
ln=0		# Line number

sed 's/$//' "$input_file" > "$tmp_file"
/bin/ls -Flh "$tmp_file"

function initUser
{
	cn=''; sn=''; uid=''; mail=''; new_person=$init_val; cn_sep=':'
}
initUser

function addUserAt
{
	if [ -z "$sn" ]	# sn is missing => using cn as sn
    then new_person="$new_person\nsn$cn_sep $cn"
    fi

	udn="uid=$uid,ou=Users,ou=TBWA-fr,$base" # user's dn
	echo $e "\nAdding: $cn ($udn) sn='$sn' at $1"
	new_person="dn: $udn\n$new_person\n\ndn: ou=addr,$udn\nobjectClass: organizationalUnit\nou: addr"
	#new_person="dn: $udn\n$new_person"	# faster but incomplete
	echo $e $new_person |nl -ba	# to debug
	echo $e $new_person |ldapadd -xcD "$bind_dn" -w "$bindpw" -h $host
	ret=$?
	if [ $ret -eq 0 ]
	then
        let nbpadded=$nbpadded+1
		echo "$nbpadded person(s) added since the start of this script."
		initUser
	else
        type xmessage >> /dev/null && xmessage -center -default okay "$cmd failed at $1."
	fi

	return $ret
}

while read line
do	let ln=$ln+1
	echo $line |grep "$access_string" >> /dev/null
	if [ $? -eq 0 ]
	then	new_person="$new_person\nmailEnabled: OK"; continue
	else	if [ -n "$line" ]
		then echo $line |grep : >> /dev/null || continue
		fi
		head -n$ln "$input_file" |tail -n1 |grep -e ^' ' -e ': '$ >> /dev/null && continue
	fi

	export IFS=': '
	set 1 $line; shift
	export IFS=' 	'

	if [ "$1" = '#' ]; then continue; fi # Ignore LDIF comments

	param="$1"; shift; val="$*"; sep=':'
	echo $line | grep -e ':: ' >> /dev/null && sep='::'

	if [ -n "$line" -a -n "$param" -a -n "$val" ]
	then	addon=''
		case "$param" in
			cn) # fields to extract value in a var
			  if [ -n "$cn" -a -n "$uid" -a -n "$sn" ]
			  then addUserAt cn || exit $?
			  fi
			  cn="$val"
			  addon="$param$sep $val"
			  cn_sep=$sep
			  ;;
			mail) if [ -n "$cn" -a -n "$uid" -a -n "$sn" -a -n "$mail" ]
			  then addUserAt mail || exit $?
			  fi
			  mail="$val"
			  addon="$param$sep $val"
			  ;;
			sn) if [ -n "$cn" -a -n "$uid" -a -n "$sn" ]
			  then addUserAt sn || exit $?
			  fi
			  sn="$val"
			  addon="$param$sep $val"
			  ;;
			department) # fields to rename
			  addon="ou$sep $val"
			  ;;
			mailNickname|sAMAccountName)
			  if [ -z "$uid" ] # to be written only once
			  then	export uid="$val"
				addon="uid$sep $val"
			  fi
			  ;;
			memberOf) # special field
			  echo $val|grep ^"$access_string" >> /dev/null && addon='mailEnabled: OK'
			  ;;
			c|l|ou|postalCode|telephoneNumber|facsimileTelephoneNumber| \
			givenName|displayName|co|street|streetAddress|title| \
			physicalDeliveryOfficeName|description|homePhone|info)
			  # fields to keep as they come
			  #$param=$val	# does not work! :(
			  set "$param" = "$val"
			  addon="$param$sep $val"
			  ;;
		esac

		if [ -n "$addon" ]
		then new_person="$new_person\n$addon"
		fi
	elif [ -z "$line" -a "$new_person" != "$init_val" -a -n "$uid" ]
	then addUserAt loop || exit $?
	fi
done < "$tmp_file"

rm -v "$tmp_file"

if [ "$new_person" != "$init_val" -a -n "$uid" ]
then addUserAt end || exit $?
fi

if [ $nbpadded -le 0 ]
then	echo "$ln lines parsed but no one added to the LDAP server! ($nbpadded)"
	type xmessage >> /dev/null && xmessage -center -default okay "$cmd is over but nothing added."
	exit 1
fi

echo "$ln lines parsed & $nbpadded person(s) added."

type xmessage >> /dev/null && xmessage -center -default okay "$cmd is over."

exit 0		# Success

# vim: ts=8 sw=8 noet
