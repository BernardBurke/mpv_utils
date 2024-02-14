#!/usr/bin/env bash

# read an edl file and create an mpv command that plays as a list
#source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 
TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)

if [[ $1 == "" ]]; then
    EDL_FILE=1
else
    if [[ -f $1 ]]; then
        EDL_FILE="$1"
    else
        message "$1 does not exit"
        exit 1
    fi
fi 


if [[ $2 == "" ]]; then
    AUDIO_FILE=""
else
    if [[ -f $2 ]]; then
        AUDIO_FILE="$2"
    else
        message "$2 does not exit"
        exit 1
    fi
    filename=$(basename -- "$AUDIO_FILE")
    extension="${filename##*.}"
    filename="${filename%.*}"
    directoryname=$(dirname -- "$AUDIO_FILE")
    SUBTITLES=true
    SUBTILES_FILE="${directoryname}/${filename}.srt"

    message "Adding $2 $SUBTILES_FILE"

fi

if [[ $3 == "" ]]; then
    OUTPUT_FILE=$USCR/edl2ply_$$.txt
else
    OUTPUT_FILE=$USCR/$3
fi 



convert_tdl_file_content() {
    MAX_SIZE=$(getconf ARG_MAX)
    NOMINAL_MAX=$((MAX_SIZE-100))
    ISIZE=0


    while IFS=, read -r file start length; do
        LION="--\{ \"$file\" --start=$start --length=$length --\} \\"    
        strlen=$(echo $LION | wc -c)
        ISIZE=$((ISIZE+strlen))
        if [[ $ISIZE -gt $MAX_SIZE ]]; then
            message "command became too long $ISIZE"
            exit 1
        fi
        echo "$LION"
        echo "$LION" >> "$2"
    done < "$1"
  
    message "$1 became $ISIZE in length vs $MAX_SIZE"
}



message "Calling convert_edl_file_content"

convert_tdl_file_content "$EDL_FILE" "$OUTPUT_FILE"

add_audio_subtiles(){
    if [[ $1 == "" ]]; then
        message "No audio file"
    else
        echo " --audio-files-add=\"$1\" \\" >> $OUTPUT_FILE
        message "Appended $1"

    fi
    if [[ $2 == "" ]]; then
        message "No subtitle file"
    else
        echo " --sub-files-add=\"$2\" \\" >> $OUTPUT_FILE
        message "Appended $2"
        
    fi

}

cat $OUTPUT_FILE | grep -v "#" > $TMPFILE2
echo "mpv --profile=override --volume=60 --screen=1 \\" > $OUTPUT_FILE
if $SUBTITLES; then
    message "Adding subtitles"
    add_audio_subtiles "$AUDIO_FILE" "$SUBTILES_FILE"
else
    message "No subtitles"
    
fi
read -p "Press return"
cat $OUTPUT_FILE 
cat $TMPFILE2 >> $OUTPUT_FILE
echo "Results --->"
cp $OUTPUT_FILE $TMPFILE1

message "Results in $TMPFILE1"

cp $OUTPUT_FILE $BATCHSRC2
bash $OUTPUT_FILE