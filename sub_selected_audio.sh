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

if [[ "$4" == "" ]]; then
        BEFORE=12
else
        BEFORE=$4
fi


if [[ "$5" == "" ]]; then
        AFTER=10
else
        AFTER=$5
fi



TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)
TMPFILE3=$(mktemp)

#find $GRLSRC -type f -iname '*.vtt' -exec grep -iH -B $BEFORE -A $AFTER "$1" "{}" \; | sort -Ru > $TMPFILE1
#find $GRLSRC2 -type f -iname '*.vtt' -exec grep -iH -B $BEFORE -A $AFTER "$1" "{}" \; | sort -Ru >> $TMPFILE1
find $AUDEY -type f -iname '*.srt' -exec grep -iH -B $BEFORE  "$1" "{}" \; | sort -Ru > $TMPFILE1
find $AUDEY2 -type f -iname '*.srt' -exec grep -iH -B $BEFORE  "$1" "{}" \; | sort -Ru >> $TMPFILE1
#cat $TMPFILE1
grep ".srt-00" $TMPFILE1 | grep -v '"' | grep -v "'" | grep -v "\[" | grep -v the-doctors | shuf -n 500 > $TMPFILE2
#sed -e 's/> /end=/g' -i $TMPFILE2
sed -e "s/>.*/length=$AFTER/g" -i $TMPFILE2
sed -e 's/.srt-/.m4a\" --start=/g' -i $TMPFILE2
sed -e 's/,/./g' -i $TMPFILE2
sed -e 's/\/mnt/\"\/mnt/g' -i $TMPFILE2
sed -e 's/\/home/\"\/home/g' -i $TMPFILE2
tr -d '\r' <$TMPFILE2 > $TMPFILE1

cat $TMPFILE1 | sort -Ru | grep -v "(" > $TMPFILE2
cp $TMPFILE2    $TMPFILE1
cat $TMPFILE1

ROW_COUNT=0
MAXROWS=10000

echo "mpv --profile=override --volume=$VOLUME --screen=$SCREEN \\" > $TMPFILE3
echo "mpv --profile=override --volume=$VOLUME --screen=$SCREEN \\" > $USCR/sub_selected_audio_$$.txt

while read -r pss; do 
        echo -e  "--\{ $pss --\} \\"  >> $TMPFILE3
        echo -e  "--\{ $pss --\} \\"  >> $USCR/sub_selected_audio_$$.txt
        ((ROW_COUNT=ROW_COUNT+1))
        if [[ ROW_COUNT -gt MAXROWS ]]; then 
                echo "Maxed out at $MAXROWS - continuing"
                break
        fi
done < "$TMPFILE1" 
read -p "Press return $ROW_COUNT"

cp $TMPFILE3 /tmp/three.sh

#nohup bash -x /tmp/three.sh &

