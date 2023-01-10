#!/bin/bash
# general purpose fuinction tester
source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

get_media_without_subtitles() {
    if [[ ! -d "$1" ]]; then
        message "$1 does not exist"
        exit 1
    fi
    DIRECTORY_NAME="$1"
    MEDIA_ARRAY=".m4a .mp3 .webm .mpv .mkv .avi .wmv .mpga"
    for mtype in $MEDIA_ARRAY
    do
        find "$1" -type f -iname "*$mtype" -exec basename -s $mtype "{}" \;>> $TMPFILE1
        find "$1" -type f -iname "*$mtype" >> $TMPFILE2
    done

    #cat $TMPFILE1

    while read -r line1
    do
        SNAME="$line1.srt"
        VNAME="$line1.vtt"
        SPATH="$DIRECTORY_NAME/$SNAME"
        VPATH="$DIRECTORY_NAME/$VNAME"

        if [[ ! -f "$SPATH"  && ! -f "$VPATH" ]]; then
            grep -i "$line1" $TMPFILE2
        fi

    done < $TMPFILE1    

}


#get_media_without_subtitles "$AUDEY/catwithclaws"
#echo $SRC/vosk_me.sh $(get_media_without_subtitles "$AUDEY/emma_patreon")
get_media_without_subtitles "$AUDEY/catwithclaws" > $TMPFILE3

while read -r l2
do
    echo "$SRC/vosk_me.sh \"$l2\""
done < $TMPFILE3
