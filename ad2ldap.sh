#!/bin/bash

# Adapted from: http://www.freesource.info/wiki/DmitriyKruglikov/Raznoe/AD2LDAP
#  by: Julien MOREAU aka PixEye
#  on the: 2009-02-23

nbps=2				# Number of wanted parameters (without option)
cmd=`basename $0`		# Name of the command
usage="Usage: $cmd [-h|--help]\n"	# Help message
usage=$usage"\tDisplay this help message.\n\n"
usage=$usage"Usage: $cmd [-b <base>] <hostname> <filename>\n"
usage=$usage"\tInject the content of AD format file <filename>\n"
usage=$usage"\t\tto the server <hostname>."

echo "\ntest"|grep -q ntest && e="-e"	# Does echo need the -e option?

if [ "$#" -ge 2 -a "$1" = '-b' ]
then base=$2; shift 2
else base=''
fi

if [ "$#" -ne "$nbps" -o "$1" = '-h' -o "$1" = '--help' ] # Check parameters number
then echo $e $usage 1>&2; exit 2		# Display help message and stop
fi

if [ ! -r "$2" ]	# Is the file argument exist and is readable?
then echo $e "File \"$2\" is not readable!\n" 1>&2; echo $e $usage 1>&2; exit 3
fi

umask 077	# Protect temporary files from being accessed by other users of the system

host="$1"
input_file="$2"
if [ -z "$base" ]; then base="dc=$host,dc=vp"; fi

tmp_file='/tmp/'`basename "$input_file"`
echo "Temporary file is: $tmp_file"
echo $e -n 'Please enter the password: '
read bindpw

init_val="objectClass: inetOrgPerson\nobjectClass: OXUserObject"
access_string='CN=Users_Veepee,'
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
	if [ -z "$sn" ]; then new_person="$new_person\nsn$cn_sep $cn"; fi	# sn is missing => using cn as sn
	udn="uid=$uid,ou=Users,ou=TBWA-fr,$base" # user's dn
	echo $e "\nAdding: $cn ($udn) sn='$sn' at $1"
	new_person="dn: $udn\n$new_person\n\ndn: ou=addr,$udn\nobjectClass: organizationalUnit\nou: addr"
	#new_person="dn: $udn\n$new_person"	# faster but incomplete
	echo $e $new_person |nl -ba	# to debug
	echo $e $new_person |ldapadd -xcD "cn=admin,$base" -w "$bindpw" -h $host
	ret=$?
	if [ $ret -eq 0 ]
	then	let nbpadded=$nbpadded+1
		echo "$nbpadded person(s) added since the start of this script."
		initUser
	else	type xmessage >> /dev/null && xmessage -center -default okay "$cmd failed at $1."
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
