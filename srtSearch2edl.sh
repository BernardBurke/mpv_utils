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

if [[ "$USE_SRT_FILES" == "yes" ]]; then

	echo "Looking for SRT files"

    find $GRLSRC/ -type f -iname '*.srt' -exec grep -iH -B 4 "$1" "{}" \;  |  grep srt\-0 > $TMP1

	sed -i -e 's/,/./g' $TMP1

	# cat $TMP1
	# read -p "Press return to continue"

	sed -i -e 's/.srt-/.mp4,/g' $TMP1

	# cat $TMP1
	# read -p "Press return to continue"

	sed -i -e  's/-->/,/g' $TMP1

elif [[ "$USE_SRT_FILES" == "audio" ]]; then

	echo "Looking for SRT files and AUDIO only"

	find $AUDEY -type f -iname '*.srt' -exec grep -iH -B 4 "$1" "{}" \;  |  grep srt\-0 > $TMP1

	sed -i -e 's/,/./g' $TMP1

	sed -i -e 's/.srt-/.m4a,/g' $TMP1

	sed -i -e  's/-->/,/g' $TMP1


else

	find $GRLSRC/pure -type f -iname '*.vtt' -exec grep -iH -B 4 "$1" "{}" \;  |  grep vtt\-0 > $TMP1
	
	sed -i -e 's/.vtt-/.mp4,/g' $TMP1

	sed -i -e  's/-->/,/g' $TMP1

fi

#cat $TMP1


saved_ifs=$IFS

check_for_mp3() {
	if [[ -f "$1" ]]; then
		echo "$1"
	else
		temp_file="$(basename .m4a)"
		temp_file="$temp_file.mp3"
		if [[ -f "$temp_file" ]]; then
			echo "$temp_file"
		else
			echo "$1"
		fi
	fi
}


while IFS=, read -r file start end 
	do
		file=$(check_for_mp3 "$file")
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

if [[ "$USE_SRT_FILES" == "audio" ]]; then
	echo "run convert_edl_playlist on the output file testeagle"
	cp -v $TMP1 $HANDUNI/testeagle.edl
else
	cp $TMP1 $HANDUNI/delicious_words_$$.edl -v
	nohup mpv $TMP1 --screen=$SCREEN --volume=$VOLUME &
	echo "$TMP1"
fi
#mpv $TMP1
