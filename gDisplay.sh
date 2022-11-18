#!/bin/bash
# use nohup mpv  config profiles to cycle imaages
#source $SRC/common_inc.sh
source $SRC/common_inc.sh

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
        RETFilename="$(find $GRLSRC/audio -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.wav' |  shuf -n 1)";;
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

source $MPVU/play_media.sh


# change to default order - play mode comes first! everything else shuffles down
if [[ $1 = "" ]]; then
    PLAY_MODE=1
else
    PLAY_MODE=$1
fi

if [[ "$2" = "" ]]; then
        VOLUME=0
else
        VOLUME=$2
fi

if [[ "$3" = "" ]]; then
        SCREEN=0
else
        SCREEN=$3
fi

if [[ "$4" = "" ]]; then
        SELECT_MODE=edl 
else
        SELECT_MODE=$4
fi


if [[ $5 = "" ]]; then
    HOW_MANY=5
else
    HOW_MANY=$5
fi

if [[ $6 = "" ]]; then
    SEARCH_STRING=a
else
    SEARCH_STRING=$6
fi

if [[ $7 = "" ]]; then
    ADD_SUBS=false
else
    ADD_SUBS=true
    SUBS_SEARCH_STRING="$7"
fi

IS_PLAYLIST=false

echo "Playing on $SCREEN at $VOLUME with mode $SELECT_MODE and searching for $SEARCH_STRING executing $HOW_MANY times in play mode $PLAY_MODE "

   

videoOnly() {
    echo "Defaulting to video only"
    VIDEO1="$(get_file_by_type "video")"
    echo "Playing $VIDEO1"
    VIDEO2="$(get_file_by_type "video")"
    echo "Playing $VIDEO2"
    VIDEO3="$(get_file_by_type "video")"
    echo "Playing $VIDEO3"
    VIDEO4="$(get_file_by_type "video")"
    echo "Playing $VIDEO4"
}


recent() {
    VIDEO1="$(get_file_by_type "recent" $FILE_AGE)"
    echo "Playing $VIDEO1"
    VIDEO2="$(get_file_by_type "recent" $FILE_AGE)"
    echo "Playing $VIDEO2"
    VIDEO3="$(get_file_by_type "recent" $FILE_AGE)"
    echo "Playing $VIDEO3"
    VIDEO4="$(get_file_by_type "recent" $FILE_AGE)"
    echo "Playing $VIDEO4"
}

vtt() {
    VIDEO1="$(get_file_by_type "vtt")"
    DIRNAME="$(dirname $VIDEO1)"
    VIDEO1="$DIRNAME/$(basename $VIDEO1 vtt)mp4"
    VIDEO2="$(get_file_by_type "vtt")"
    DIRNAME="$(dirname $VIDEO2)"
    VIDEO2="$DIRNAME/$(basename $VIDEO2 vtt)mp4"
    VIDEO3="$(get_file_by_type "vtt")"
    DIRNAME="$(dirname $VIDEO3)"
    VIDEO3="$DIRNAME/$(basename $VIDEO3 vtt)mp4"
    VIDEO4="$(get_file_by_type "vtt")"
    DIRNAME="$(dirname $VIDEO4)"
    VIDEO4="$DIRNAME/$(basename $VIDEO4 vtt)mp4"
}

edlblend() {
    TMPFILE4=$(mktemp)
    TMPFILE5=$(mktemp)
    TMPFILE6=$(mktemp)
    TMPFILE7=$(mktemp)
    get_file_by_type "edlblend" "$SEARCH_STRING" "$HOW_MANY"
    cp -v $TMPFILE1 $TMPFILE4
    VIDEO1="$TMPFILE4"
    get_file_by_type "edlblend" "$SEARCH_STRING" "$HOW_MANY"
    cp -v $TMPFILE1 $TMPFILE5
    VIDEO2="$TMPFILE5"        
    get_file_by_type "edlblend" "$SEARCH_STRING" "$HOW_MANY"
    cp -v $TMPFILE1 $TMPFILE6
    VIDEO3="$TMPFILE6"
    get_file_by_type "edlblend" "$SEARCH_STRING" "$HOW_MANY"
    cp -v $TMPFILE1 $TMPFILE7
    VIDEO4="$TMPFILE7"   
}

edlm3u() {
    TMPFILE4=$(mktemp)
    TMPFILE5=$(mktemp)
    TMPFILE6=$(mktemp)
    TMPFILE7=$(mktemp)
    get_file_by_type "edlm3u" "$SEARCH_STRING" "$HOW_MANY"
    cp $TMPFILE3 $TMPFILE4
    VIDEO1="$TMPFILE4"
    get_file_by_type "edlm3u" "$SEARCH_STRING" "$HOW_MANY"
    cp $TMPFILE3 $TMPFILE5
    VIDEO2="$TMPFILE5"        
    get_file_by_type "edlm3u" "$SEARCH_STRING" "$HOW_MANY"
    cp $TMPFILE3 $TMPFILE6
    VIDEO3="$TMPFILE6"
    get_file_by_type "edlm3u" "$SEARCH_STRING" "$HOW_MANY"
    cp $TMPFILE3 $TMPFILE7
    VIDEO4="$TMPFILE7"
    IS_PLAYLIST=true  
}

m3uSearch() {
    echo "Finding some $SEARCH_STRING"
    VIDEO1="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    VIDEO2="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    VIDEO3="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    VIDEO4="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    echo $VIDEO1
    IS_PLAYLIST=true 
}

m3u() {
    VIDEO1="$(get_file_by_type "m3u")"
    VIDEO2="$(get_file_by_type "m3u")"
    VIDEO3="$(get_file_by_type "m3u")"
    VIDEO4="$(get_file_by_type "m3u")"
    IS_PLAYLIST=true
}

edl() {
    TMPFILE4=$(mktemp)
    TMPFILE5=$(mktemp)
    SUBJ="$(get_file_by_type "edl")"
    shuffle_edl "$SUBJ" $HOW_MANY
    cat $TMPFILE1 > $TMPFILE2
    VIDEO1="$TMPFILE2"
    SUBJ="$(get_file_by_type "edl")"
    shuffle_edl "$SUBJ" $HOW_MANY
    cat $TMPFILE1 > $TMPFILE3
    VIDEO2="$TMPFILE3"
    SUBJ="$(get_file_by_type "edl")"
    shuffle_edl "$SUBJ" $HOW_MANY
    cat $TMPFILE1 > $TMPFILE4
    VIDEO3="$TMPFILE4"
    SUBJ="$(get_file_by_type "edl")"
    shuffle_edl "$SUBJ" $HOW_MANY
    cat $TMPFILE1 > $TMPFILE5
    VIDEO4="$TMPFILE5"
}

imago() {
    find /mnt/d/grls/images2/ -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 > $TMPFILE1
    VIDEO1=$TMPFILE1
    PLAY_MODE=8
    IS_PLAYLIST=true
}

rx_processing() {
        SRT_FILE="$(find $GRLSRC/audio/ -iname '*.srt' | grep -i "$1" | shuf -n 1)"
}

case "$SELECT_MODE" in
    videoOnly)
        echo "executing video only"
        videoOnly
    ;;
    recent)
        echo "executing recent only"
        recent
    ;;
    vtt)
        echo "executing vtt"
        vtt
    ;;
    edlblend)
        echo "executing edl blend"
        edlblend
    ;;
    edlm3u)
        echo "executing edl m3u"
        PLAY_MODE="${PLAY_MODE}_m3u"
        edlm3u
    ;;
    m3uSearch)
        echo "executing m3uSearch"
        PLAY_MODE="${PLAY_MODE}_m3u"
        m3uSearch
    ;;
    m3u)
        echo "executing m3u"
        PLAY_MODE="${PLAY_MODE}_m3u"
        m3u
    ;;
    edl)
        echo "executing edl classic"
        edl
    ;;
    imago)
        echo "executing imago"
        imago
    ;;
    rx)
        echo "executing rx calling m3uSearch  for now"
        #m3uSearch
        #edlm3u
        edlblend
        IS_PLAYLIST=false
        rx_processing "$SUBS_SEARCH_STRING"
        if [[ ! -f "$SRT_FILE" ]]; then
            "Cannot file SRT_FILE  from $SEARCH_STRING"
            exit 1
        fi
        PLAY_MODE=${PLAY_MODE}_subs
        ;;
    *)
    echo "invalid SELECT_MODE - exiting"
    exit 1
    ;;
esac


play_6_stub() {
        # I might make imago smarter, but for now, just a find in this case
        find /mnt/d/grls/images2/ -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 > $TMPFILE1
        play_6 "$VIDEO1" "$VIDEO2" $TMPFILE1 $VOLUME $SCREEN

}

echo "Playing mode $PLAY_MODE"



case "$PLAY_MODE" in
        "1")
        play_1 "$VIDEO1" $VOLUME $SCREEN;;
        "1_m3u")
        play_1_m3u "$VIDEO1" $VOLUME $SCREEN;;
        "1_subs")
        echo "in play_1_subs call"
        play_1_subs "$VIDEO1" "$SRT_FILE" $VOLUME $SCREEN
        ;;
        "4")
        play_4 "$VIDEO1" $VOLUME $SCREEN;;
        "4_m3u")
        play_4_m3u "$VIDEO1" $VOLUME $SCREEN;;
        "6")
        play_6_stub;;
        "6_m3u")
        play_6_stub;;
        "8")
        play_8 "$VIDEO1" $VOLUME $SCREEN;;
        *)
        echo "Invalid play_media code $PLAY_MODE";;
esac

echo "storing runtime parameters $(basename "$0" .sh)_$SCREEN.sh"
echo "$MPVU/$(basename $0)" "$1" "$2" "$3" "$4" "$5" "$6" "$7" >> /mnt/d/batch/$(basename "$0" .sh)_$SCREEN.sh
