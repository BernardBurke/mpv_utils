#!/usr/bin/env bash
TMP1=$(mktemp)
TMP2=$(mktemp)

if [[ "$1" == "" ]]; then
	echo "Please provide some search criteria"
	exit
fi

if [[ "$2" == "" ]]; then
	SCREEN=1
else
	SCREEN=$2
fi

if [[ "$3" == "" ]]; then
	VOLUME=20
else
	VOLUME=$3
fi

time_lord() {
	echo "$1" | awk -F':'  '{ print $1*3600 + $2*60 + $3 }'

}

diff() {
    diff="$(echo $2 - $1 | bc)"
    echo $diff
}



echo $str


find $GRLSRC/pure -type f -iname '*.vtt' -exec grep -iH -B 4 "$1" "{}" \;  |  grep vtt\-0 > $TMP1

sed -i -e 's/.vtt-/.mp4,/g' $TMP1

sed -i -e  's/-->/,/g' $TMP1

#cat $TMP1


saved_ifs=$IFS


while IFS=, read -r file start end 
	do
		if [[ -f "$file" ]]; then

			START=$(time_lord "$start")
			END=$(time_lord "$end")
			START=$(echo $START - 6 | bc)
			END=$(echo $END + 6 | bc )
			DIFFIE=$(diff $START $END)
			echo "$file","$START","$DIFFIE" >> $TMP2
		else
			echo "Skipping $file"
		fi
	done < $TMP1

echo "# mpv EDL v0" > $TMP1

cat $TMP2 | sort -Ru | shuf -n 100 >> $TMP1

cp $TMP1 $HANDUNI/delicious_words_$$.edl -v
nohup mpv $TMP1 --screen=$SCREEN --volume=$VOLUME &

#mpv $TMP1
