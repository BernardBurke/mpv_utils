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
#sed -e 's/> /end=/g' -i $TMPFILE2
sed -e 's/>.*/length=10/g' -i $TMPFILE2
sed -e 's/.vtt-/.mp4\" --start=/g' -i $TMPFILE2
sed -e 's/\/mnt/\"\/mnt/g' -i $TMPFILE2
tr -d '\r' <$TMPFILE2 > $TMPFILE1
 
ROW_COUNT=0
MAXROWS=10000

echo "mpv --profile=override --volume=$VOLUME --screen=$SCREEN \\" > $TMPFILE3
while read -r pss; do 
        echo -e  "--\{ $pss --\} \\"  >> $TMPFILE3
        echo -e  "--\{ $pss --\} \\"  >> $USCR/sub_selected_$$.txt
        ((ROW_COUNT=ROW_COUNT+1))
        if [[ ROW_COUNT -gt MAXROWS ]]; then 
                echo "Maxed out at $MAXROWS - continuing"
                break
        fi
done < "$TMPFILE1" 
read -p "Press return $ROW_COUNT"

cp $TMPFILE3 /tmp/two.sh

bash -x /tmp/two.sh

