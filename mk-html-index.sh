#!/bin/sh

# 2013-04-17 Created by J Moreau AKA PixEye

echo "\ntest"|grep -q ntest && e="-e"	# Does 'echo' need the -e option?

if test "$#" -eq 0 -o "$1" = "-h" -o "$1" = "--help"
then echo "Usage: $cmd \"title\"" ; exit 1
fi

if [ "$#" -ge 1 ]
then t="$*"
else t="Auto-generated index for openACS (CWMP server)"
fi

fname="index.html"
fontsize="12px"

echo '<!DOCTYPE html>' > "$fname"
echo "<html>" >> "$fname"
echo " <head>" >> "$fname"
echo "  <meta http-equiv=\"Content-Type\" content=\"text/html charset=utf-8\"/>" >> "$fname"
echo "  <title>$t</title>" >> "$fname"
echo " </head>" >> "$fname"
echo " <body>" >> "$fname"
echo "  <h1 style=\"margin:0 9px 9px\">$t</h1>" >> "$fname"
echo "  <ul style=\"font-size:$fontsize\">" >> "$fname"
 
for f in */*.*htm* *.*htm*
do
	if test "$f" = "index.xhtml"
	then continue
	fi

	t=`echo $f|sed 's|\..*htm.*$||'`
	echo "$f -> $t"
	echo "   <li><a href=\"$f\">$t</a></li>" >> "$fname"
done

echo -n$e "  </ul>\n </body>\n</html>" >> "$fname"

exit 0

# vim: noexpandtab
