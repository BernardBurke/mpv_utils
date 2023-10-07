#!/usr/bin/env bash
TMP1=$(mktemp)
TMP2=$(mktemp)

if [[ "$1" == "" ]]; then
	echo "Please provide some search criteria"
	exit
fi

time_lord() {
	echo "$1" | awk -F':'  '{ print $1*3600 + $2*60 + $3 }'

}

diff() {
    diff="$(echo $2 - $1 | bc)"
    echo $diff
}

find $GRLSRC/pure -type f -iname '*.vtt' -exec grep -iH -B 4 "$1 $2 $3 " "{}" \;  |  grep vtt\-0 > $TMP1

sed -i -e 's/.vtt-/.mp4,/g' $TMP1

sed -i -e  's/-->/,/g' $TMP1

#cat $TMP1


saved_ifs=$IFS


while IFS=, read -r file start end 
do
	START=$(time_lord "$start")
	END=$(time_lord "$end")
	DIFFIE=$(diff $START $END)
	echo "$file","$START","$DIFFIE" >> $TMP2
done < $TMP1

echo "# mpv EDL v0" > $TMP1

cat $TMP2 | sort -Ru >> $TMP1

echo $TMP1
