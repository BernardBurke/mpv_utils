#!/usr/bin/env bash
# use nohup mpv --image-display-duration=$DISPLAY_TIME config profiles to cycle imaages
# source $SRC/common_inc.sh
TMPFILE1=$(mktemp) 
TMPFILE2=$(mktemp)
TMPFILE3=$(mktemp)

get_file_by_type() {
    case "$1" in
        "edl")
        RETFilename="$(find $EDLSRC/ -iname '*.edl' | grep unix | shuf -n 1)";;
        "video")
        RETFilename="$(find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | shuf -n 1)";;
        "recent")
        if [[ $2 = "" ]]; then
            AGE=7
        else
            AGE=$2
        fi
        RETFilename="$(find $GRLSRC/ \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' \) -mtime -$AGE | shuf -n 1)";;
        "audio")
        RETFilename="$(find $AUDEY -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.wav' |  shuf -n 1)";;
        "srt")
        RETFilename="$(find $GRLSRC/ -iname '*.srt' | shuf -n 1)";;
        "vtt")
        RETFilename="$(find $GRLSRC/ -iname '*.vtt' | shuf -n 1)";;
        "subtitle")
        RETFilename="$(find $GRLSRC/ -iname '*.vtt' -o -iname '*.srt' |  shuf -n 1)";;
        "m3u")
        find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | shuf -n 10 > $TMPFILE3
        RETFilename=$TMPFILE3;;
        "m3uSearch")
        find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' > $TMPFILE1
        cat $TMPFILE1 | grep -i "$2" | shuf -n $3 > $TMPFILE3
        RETFilename=$TMPFILE3;;
        "edlm3u")
        find $EDLSRC/ -iname '*.edl' | grep unix | grep -i "$2" | shuf -n $3 > $TMPFILE3
        ;;
        "edlblend")
        echo "edlblend searching for $2 and shuffling for $3..."
        find $EDLSRC/ -iname '*.edl' | grep unix | grep -i "$2" > $TMPFILE1
        while read -r edlname; do
            cat "$edlname" | grep -v "#" >> $TMPFILE2
        done < $TMPFILE1
        shuffle_edl $TMPFILE2 $3
        ;;
        *) echo "Invalid filetype $1"
        exit 1;;
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

# SUBJ=$(get_file_by_type "edlm3u" "mom" 20)

# cat $TMPFILE3

# SUBJ="$(get_file_by_type "edl")"

# shuffle_edl "$SUBJ" 50

# cat $TMPFILE1
#get_file_by_type "edl"