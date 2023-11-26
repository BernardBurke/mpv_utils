if [[ "$1" == "" ]]; then
	echo "$1 provide a quoted search string "
	exit
fi

if [[ "$2" == "" ]]; then
        SCREEN=1
else
        SCREEN=$2
fi

if [[ "$3" == "" ]]; then
        VOLUME=10
else
        VOLUME=$3
fi

TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)
TMPFILE3=$(mktemp)

find $GRLSRC -type f -iname '*.vtt' -exec grep -iH -B 4 -A 4 "$1" "{}" \; | sort -Ru > $TMPFILE1
grep ".vtt-00" $TMPFILE1 > $TMPFILE2
sed -e 's/> /end=/g' -i $TMPFILE2
sed -e 's/.vtt-/.mp4\" --start=/g' -i $TMPFILE2
sed -e 's/\/mnt/\"\/mnt/g' -i $TMPFILE2
tr -d '\r' <$TMPFILE2 > $TMPFILE1
 

echo "mpv --profile=override --volume=$VOLUME --screen=$SCREEN \\" > $TMPFILE3
while read -r pss; do 
	echo -e  "--\{ $pss --\} \\"  >> $TMPFILE3
done < "$TMPFILE1" 

cp $TMPFILE3 /tmp/two.sh

bash -x /tmp/two.sh

