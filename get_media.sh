#!/bin/bash
# use nohup mpv --image-display-duration=$DISPLAY_TIME config profiles to cycle imaages
source $SRC/common_inc.sh

get_file_by_type() {
    case "$1" in
        "edl")
        RETFilename="$(find $EDLSRC/ -iname '*.edl' | grep unix | shuf -n 1)";;
        "video")
        RETFilename="$(find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | shuf -n 1)";;
        "audio")
        RETFilename="$(find $GRLSRC/audio -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.wav' |  shuf -n 1)";;
        "srt")
        RETFilename="$(find $GRLSRC/ -iname '*.srt' | shuf -n 1)";;
        "vtt")
        RETFilename="$(find $GRLSRC/ -iname '*.vtt' | shuf -n 1)";;
        "subtitle")
        RETFilename="$(find $GRLSRC/ -iname '*.vtt' -o -iname '*.srt' |  shuf -n 1)";;
        *) echo "Invalid filetype $1";;
    esac

    echo "$RETFilename"

}

shuffle_edl() {

    if [[ $2 = "" ]]; then
        SHUFN=100
    else
        SHUFN="$2"
    fi
    echo "# mpv EDL v0" > $TMPFILE1
    if [[ -f $1 ]]; then
        cat "$1" | grep -v "#" | shuf -n $SHUFN >> $TMPFILE1
    else
        return 1
    fi 
    
}



# SUBJ="$(get_file_by_type "edl")"

# shuffle_edl "$SUBJ" 50

# cat $TMPFILE1
#get_file_by_type "edl"