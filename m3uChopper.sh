#!/bin/bash
# a more serious version of this converter - written initially to check a windows edl
source $SRC/common_inc.sh

if [[ ! -f "$1" ]]; then
    echo "Please provice an M3U file that exists"
    exit 1
fi

FSTUB="$(basename "$1" .m3u)"

echo $FSTUB

if [[ "$2" = "" ]]; then
        SLICE=10
else
        SLICE=$2
fi

if [[ "$3" = "" ]]; then
        LOOP_COUNT=10
else
        LOOP_COUNT=$3
fi


if [[ "$4" = "" ]]; then
        VARIANCE=5
else
        VARIANCE=$4
fi

#echo "Slice time is $SLICE"


LOWER=$[SLICE - $VARIANCE]
UPPER=$[SLICE + $VARIANCE]

cat $SBTW/choice.words2 | shuf -n 400 > $SBTW/choice.words1
cat $SBTW/choice.words1 | shuf -n 400 > $SBTW/choice.words3
cat $SBTW/choice.words1 | shuf -n 400 > $SBTW/choice.words2

j=0
k=0

echo "# mpv EDL v0" > $TMPFILE1

sed -i 's/\r$//' "$1" # get rid of those pesky carriage returns

while IFS= read -r fname; do
    #nixname=$(wslpath -u "$fname" | tr -d '\r' )
    nixname=$"$fname"
    #echo $nixname
    j=0
    leng=$(ffprobe -v quiet  -of csv=p=0 -show_entries format=duration "$nixname")
#    echo $leng
    length=${leng%.*}
    if [[ ! -z "$length" ]]; then
        #echo "$fname $length"
            for ((j=1;j<=$LOOP_COUNT;j++)); do
                    period=$(shuf -i $LOWER-$UPPER -n 1 )
                    strt=$(rand -M $length -s $RANDOM )
                    runtime=$(( $strt + $period ))
                    #echo "Length $length Start $strt Period $period Runtime $runtime fname $fname"
                    #echo "Runtime $runtime"
                    if [ "$length" -gt "$runtime" ]; then
                            #period=$[ "$period" - "1" ]
                            #echo "$fname,$strt,$period" 
                            echo "$fname,$strt,$period" >> $TMPFILE2
                            ((k++))
                    else
                            echo "runtime greater than length"
                            break
                    fi
            done
    fi

done < "$1"

OUT1="${HANDUNI}/${FSTUB}_chopped1.edl"
OUT2="${HANDUNI}/${FSTUB}_chopped2.edl"
OUT3="${HANDUNI}/${FSTUB}_chopped3.edl"

cat $TMPFILE2 | shuf -n $k  >> $TMPFILE1
echo "# mpv EDL v0" > "$OUT1"
cat $TMPFILE1 | shuf -n $k >> "$OUT1"
echo "# mpv EDL v0" > "$OUT2"
cat $TMPFILE1 | shuf -n $k >> "$OUT2"
echo "# mpv EDL v0" > "$OUT3"
cat $TMPFILE1 | shuf -n $k >> "$OUT3"

ls "$OUT1"


#echo $(wslpath -w "$TMPFILE1")