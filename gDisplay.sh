#!/usr/bin/env bash
# use nohup mpv  config profiles to cycle imaages
#source $SRC/common_inc.sh
# source $SRC/common_inc.sh
TMPFILE1=$(mktemp) 
TMPFILE2=$(mktemp)
TMPFILE3=$(mktemp)

source $MPVU/util_inc.sh 

SCRATCH_DIR="$(mktemp -d)"

get_file_by_type() {
    case "$1" in
        "edl")
        RETFilename="$(find $EDLSRC/ -iname '*.edl' | grep unix | shuf -n 1)";;
        "video")
        RETFilename="$(find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | grep -i "$2"| shuf -n 1)";;
        "audio")
        RETFilename="$(find $$AUDEY -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.wav' |  shuf -n 1)";;
        "srt")
        RETFilename="$(find $GRLSRC/ -iname '*.srt' | shuf -n 1)";;
        "subtitle")
        RETFilename="$(find $GRLSRC/ -iname '*.vtt' -o -iname '*.srt' |  shuf -n 1)";;
        "m3u")
        find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | shuf -n 10 > $TMPFILE3
        RETFilename=$TMPFILE3;;
        *) echo "Invalid filetype $1"
        exit 1;;
    esac

    echo "$RETFilename"

}

# shuffle_edl() {

#     if [[ $2 = "" ]]; then
#         SHUFN=100
#     else
#         SHUFN="$2"
#     fi
#     echo "# mpv EDL v0" > $TMPFILE1
#     if [[ -f $1 ]]; then
#         cat "$1" | grep -v "#" | shuf -n $SHUFN >> $TMPFILE1
#     else
#         return 1
#     fi 
#     message "shuffle_edl wrote $TMPFILE1"
# }

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
    SUBS_SEARCH_STRING=""$7""
    message "SUBS_SEARCH_STRING is $SUBS_SEARCH_STRING"
fi

IS_PLAYLIST=false

echo "Playing on $SCREEN at $VOLUME with mode $SELECT_MODE and searching for $SEARCH_STRING executing $HOW_MANY times in play mode $PLAY_MODE "

blank4_videos() {
    VIDEO1=$(mktemp)
    VIDEO2=$(mktemp)
    VIDEO3=$(mktemp)
    VIDEO4=$(mktemp)
}
   

videoOnly() {
    echo "Defaulting to video only"
    VIDEO1="$(get_file_by_type "video" "$SEARCH_STRING")"
    echo "Playing $VIDEO1"
    VIDEO2="$(get_file_by_type "video" "$SEARCH_STRING")"
    echo "Playing $VIDEO2"
    VIDEO3="$(get_file_by_type "video" "$SEARCH_STRING")"
    echo "Playing $VIDEO3"
    VIDEO4="$(get_file_by_type "video" "$SEARCH_STRING")"
    echo "Playing $VIDEO4"
}


recent() {
    if [[ $1 = "" ]]; then
        AGE=7
    else
        AGE=$HOW_MANY
    fi
    message "Creating playlists for $AGE day old files" 
    blank4_videos

    find $GRLSRC/ \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' \) -mtime -$AGE | shuf -n 100 > $VIDEO1
    find $GRLSRC/ \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' \) -mtime -$AGE | shuf -n 100 > $VIDEO2
    find $GRLSRC/ \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' \) -mtime -$AGE | shuf -n 100 > $VIDEO3
    find $GRLSRC/ \( -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' \) -mtime -$AGE | shuf -n 100 > $VIDEO4

    message "Going to play $VIDEO1...$VIDEO2...$VIDEO3...$VIDEO4"

    IS_PLAYLIST=true 
}

vtt() {
    blank4_videos
    
    find $GRLSRC/ -iname '*.vtt' | shuf -n $HOW_MANY > $VIDEO1
    find $GRLSRC/ -iname '*.vtt' | shuf -n $HOW_MANY > $VIDEO2
    find $GRLSRC/ -iname '*.vtt' | shuf -n $HOW_MANY > $VIDEO3
    find $GRLSRC/ -iname '*.vtt' | shuf -n $HOW_MANY > $VIDEO4

    sed -i "s/.vtt/.mp4/g" $VIDEO1 
    sed -i "s/.vtt/.mp4/g" $VIDEO2
    sed -i "s/.vtt/.mp4/g" $VIDEO3 
    sed -i "s/.vtt/.mp4/g" $VIDEO4

    RANDOM_SUBTITLES=false 

    # VIDEO1="$DIRNAME/$(basename $VIDEO1 vtt)mp4"
    # DIRNAME="$(dirname $VIDEO2)"
    # VIDEO2="$DIRNAME/$(basename $VIDEO2 vtt)mp4"
    # VIDEO3="$(get_file_by_type "vtt")"
    # DIRNAME="$(dirname $VIDEO3)"
    # VIDEO3="$DIRNAME/$(basename $VIDEO3 vtt)mp4"
    # VIDEO4="$(get_file_by_type "vtt")"
    # DIRNAME="$(dirname $VIDEO4)"
    # VIDEO4="$DIRNAME/$(basename $VIDEO4 vtt)mp4"

    IS_PLAYLIST=true

}



make4_videos() {
    message "Creating 4 VIDEO files"
    blank4_videos
    message "shuffling $HOW_MANY records for VIDEO1"
    shuffle_edl $1 $HOW_MANY
    cp -v $TMPFILE1 $VIDEO1
    # message "$VIDEO1 contents ---"
    # cat $VIDEO1
    # message "shuffling $HOW_MANY records for VIDEO2"
    shuffle_edl $1 $HOW_MANY
    cp -v $TMPFILE1 $VIDEO2
    message "shuffling $HOW_MANY records for VIDEO3"
    shuffle_edl $1 $HOW_MANY
    cp -v $TMPFILE1 $VIDEO3
    message "shuffling $HOW_MANY records for VIDEO4"
    shuffle_edl $1 $HOW_MANY
    cp -v $TMPFILE1 $VIDEO4

}

edlblend() {
    TMPFILE7="$(mktemp)"
    message "edlblend searching for $SEARCH_STRING and shuffling for $HOW_MANY..."
    # put movies back infind $EDLSRC/ -iname '*.edl' | grep unix | grep -v movies | grep -i "$SEARCH_STRING" > $TMPFILE7
    find $EDLSRC/ -iname '*.edl' | grep unix | grep -i "$SEARCH_STRING" > $TMPFILE7
    find $USCR/ -iname '*.edl' | grep -i "$SEARCH_STRING" >> $TMPFILE7

    message "dumping search results for $SEARCH_STRING"
    cat $TMPFILE7

    message "edlblend wrote to $TMPFILE7"
    message "edlblend reading $(wc -l $TMPFILE7) records from $TMPFILE7"
    while read -r edlname; do
        cat "$edlname" | grep -v "#" >> $TMPFILE2
    done < $TMPFILE7
    make4_videos $TMPFILE2
    message "$VIDEO1 is VIDEO1"
}

edlm3u() {
    #message "edlm3u is probably defunct - calling edlm3u"
    #message "m3u is probably defunct - callling edlblend..."
    # exit 1
    message  " edlm3u searching for $SEARCH_STRING and shuffling for $HOW_MANY..."
    TMPFILE8=$(mktemp)
    find $EDLSRC/ -type f -iname '*.m3u' | grep unix | grep -i "$SEARCH_STRING"  > $TMPFILE3
    find $USCR/ -type f -iname '*.m3u' | grep unix | grep -i "$SEARCH_STRING"  >> $TMPFILE3

    message "Search results in $TMPFILE3"
    cat $TMPFILE3

    while  read -u 3 file
    do
        message "$file is current record"
        while read -r record
        do 
            RTYPE="${record##*.}"
            if [[ "$RTYPE" == "edl" ]] ; then
                    #message "processing $record..."
                    cat "$record" | grep -v "#" >> $TMPFILE8
            else
                message "$file is not an edl file - $RTYPE"
            fi
        done < "$file"
    done 3< $TMPFILE3
        
    cat $TMPFILE8 | shuf -n $HOW_MANY > $TMPFILE3

    blank4_videos
    echo "# mpv EDL v0" > $VIDEO1
    cat $TMPFILE3 | shuf -n $HOW_MANY >> $VIDEO1
    echo "# mpv EDL v0" > $VIDEO2
    cat $TMPFILE3 | shuf -n $HOW_MANY >> $VIDEO2
    echo "# mpv EDL v0" > $VIDEO3
    cat $TMPFILE3 | shuf -n $HOW_MANY >> $VIDEO3
    echo "# mpv EDL v0" > $VIDEO4
    cat $TMPFILE3 | shuf -n $HOW_MANY >> $VIDEO4

    message "Candidate file for make4_videos is $TMPFILE8"
    # cp -v $TMPFILE8 $VIDEO1
    # cp -v $TMPFILE8 $VIDEO2
    # cp -v $TMPFILE8 $VIDEO3
    # cp -v $TMPFILE8 $VIDEO4

    IS_PLAYLIST=false
    export SUPPRESS_SUBTITLES=true
    #PLAY_MODE=1
}

m3uSearch() {
    message "m3uSearch is looking for $SEARCH_STRING and shuffling for $HOW_MANY"
    find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' > $TMPFILE1
    records=$(wc -l $TMPFILE1)
    message "records found = $records"
    blank4_videos
    cat $TMPFILE1 | grep -i "$SEARCH_STRING" | shuf -n $HOW_MANY > $VIDEO1
    cat $TMPFILE1 | grep -i "$SEARCH_STRING" | shuf -n $HOW_MANY > $VIDEO2
    cat $TMPFILE1 | grep -i "$SEARCH_STRING" | shuf -n $HOW_MANY > $VIDEO3
    cat $TMPFILE1 | grep -i "$SEARCH_STRING" | shuf -n $HOW_MANY > $VIDEO4
    records=$(wc -l $VIDEO1)
    message "records found = $records"
    # todo - integer comparison
    # if [[ $records -lt 1 ]]; then
    #     message "No video filenames found with $SEARCH_STRING"
    #     exit 1
    # fi 
    # VIDEO1="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    # VIDEO2="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    # VIDEO3="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    # VIDEO4="$(get_file_by_type "m3uSearch" "$SEARCH_STRING" "$HOW_MANY")"
    # echo $VIDEO1
    IS_PLAYLIST=true 
}

m3u() {
    message "m3u is probably defunct - callling m3uSearch..."
    # m3uSearch
    # exit 1
    # VIDEO1="$(get_file_by_type "m3u")"
    # VIDEO2="$(get_file_by_type "m3u")"
    # VIDEO3="$(get_file_by_type "m3u")"
    # VIDEO4="$(get_file_by_type "m3u")"
    # IS_PLAYLIST=true
    VIDEO="$(find $EDLSRC/ -iname '*.m3u' | grep -iv windows | grep -i "$SEARCH_STRING" | shuf -n 1 )"
    message "Located $VIDEO"
    # if [[ ! -f "$VIDEO" ]]; then 
    #     VIDEO="$(find $EDLSRC/ -iname '*.m3u' | grep -i "$SEARCH_STRING" | shuf -n 1 )"
    # fi

    if [[ ! -f "$VIDEO" ]]; then 
        message "No m3u file found with search string $SEARCH_STRING"
        exit 1
    fi
    VIDEO1="$VIDEO"
    VIDEO2="$VIDEO"
    VIDEO3="$VIDEO"
    VIDEO4="$VIDEO"
    IS_PLAYLIST=true
    
}

edl() {
    message "edlm3u is probably defunct - calling edlblend..."
    edlblend
    # exit 1
    # TMPFILE4=$(mktemp)
    # TMPFILE5=$(mktemp)
    # SUBJ="$(get_file_by_type "edl")"
    # shuffle_edl "$SUBJ" $HOW_MANY
    # cat $TMPFILE1 > $TMPFILE2
    # VIDEO1="$TMPFILE2"
    # SUBJ="$(get_file_by_type "edl")"
    # shuffle_edl "$SUBJ" $HOW_MANY
    # cat $TMPFILE1 > $TMPFILE3
    # VIDEO2="$TMPFILE3"
    # SUBJ="$(get_file_by_type "edl")"
    # shuffle_edl "$SUBJ" $HOW_MANY
    # cat $TMPFILE1 > $TMPFILE4
    # VIDEO3="$TMPFILE4"
    # SUBJ="$(get_file_by_type "edl")"
    # shuffle_edl "$SUBJ" $HOW_MANY
    # cat $TMPFILE1 > $TMPFILE5
    # VIDEO4="$TMPFILE5"
}

collect_images() {
    if [[ "$IMAGE_ARRAY" == "" ]]; then
        IMAGE_ARRAY="newmaisey maizCHR gallery-dl handpinned filter senxxu senxxu tmbx tumbling_fillets vfillets"
        IMAGE_ARRAY="newmaisey newbies newest maizCHR handpinned filter tumbling_fillets vfillets toktmb"
    else
        message="Custom images $IMAGE_ARRAY"
    fi
    
    for folder in $IMAGE_ARRAY
    do 
          find $IMGSRC/$folder -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 >> $TMPFILE1
    done


}

collect_archives() {
    find $IMGSRC/ -iname '*.rar' -o -iname '*.zip'  | shuf -n 100 >> $TMPFILE1
}

imago() {
    collect_images
    collect_archives
    cat $TMPFILE1 | shuf -n 1000 > $TMPFILE2
    VIDEO1=$TMPFILE2
    PLAY_MODE=8
    IS_PLAYLIST=true
}

rx_processing() {
        WITHOUT_BRACKETS="$(echo "$1" | sed "s/\[/\\\[/g" | sed "s/\]/\\\]/g")"
        echo "withoutbrackets is ${WITHOUT_BRACKETS}"
        SRT_FILE="$(find $AUDEY/ -iname '*.srt' | grep -i "$WITHOUT_BRACKETS" | shuf -n 1)"
        echo "SRT_FILE is ${SRT_FILE}"
}

rx_dispatch() {
        IS_PLAYLIST=false
        rx_processing "$SUBS_SEARCH_STRING"
        VIDEO1="$(find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | grep -i "$SEARCH_STRING" | grep -v images2 | grep -v delphine | shuf -n 1)"
        VIDEO2="$(find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | grep -i "$SEARCH_STRING" | grep -v images2 | shuf -n 1)"
        VIDEO3="$(find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | grep -i "$SEARCH_STRING" | grep -v images2 | shuf -n 1)"
        VIDEO4="$(find $GRLSRC/ -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' | grep -i "$SEARCH_STRING" | grep -v images2 | shuf -n 1)"

        if [[ ! -f "$SRT_FILE" ]]; then
            "Cannot file SRT_FILE  from $SEARCH_STRING"
            exit 1
        fi
        PLAY_MODE=${PLAY_MODE}_subs
}

case "$SELECT_MODE" in
    videoOnly)
        echo "executing video only"
        videoOnly
    ;;
    recent)
        echo "executing recent only"
        PLAY_MODE="${PLAY_MODE}_m3u"
        recent $HOW_MANY
    ;;
    vtt)
        echo "executing vtt"
        PLAY_MODE="${PLAY_MODE}_m3u"
        vtt
    ;;
    edlblend)
        echo "executing edl blend"
        edlblend
    ;;
    edlm3u)
        echo "executing edlm3u"
        PLAY_MODE="${PLAY_MODE}"
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
    rxv)
        echo "executing rxv calling video"
        #videoOnly
        rx_dispatch
    ;;
    rxe)
        echo "executing rxe calling edl"
        edl
        IS_PLAYLIST=false
        rx_processing "$SUBS_SEARCH_STRING"

        if [[ ! -f "$SRT_FILE" ]]; then
            "Cannot file SRT_FILE  from $SEARCH_STRING"
            exit 1
        fi
        PLAY_MODE=${PLAY_MODE}_subs

    ;;
    rxm) 
        echo "executing rxm calling m3u"
        m3u

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
        #find $IMGSRC/ -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 > $TMPFILE1
        # find $IMGSRC/newmaisey -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 > $TMPFILE1
        # find $IMGSRC/slices -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 >> $TMPFILE1
        # find $IMGSRC/ten9a -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 >> $TMPFILE1
        collect_images
        #imago
        play_6 "$VIDEO1" "$VIDEO2" $TMPFILE1 $VOLUME $SCREEN

}

echo "Playing mode $PLAY_MODE"



case "$PLAY_MODE" in
        "1")
        play_1 "$VIDEO1" $VOLUME $SCREEN;;
        "1_m3u")
        play_1_m3u "$VIDEO1" $VOLUME $SCREEN;;
        "1_subs")
        echo "in play_1_subs call for $VIDEO1 $SRT_FILE"
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
echo "$MPVU/$(basename $0)" "$1" "$2" "$3" "$4" "$5" "$6" "$7" >> $BATCHSRC/$(basename "$0" .sh)_$SCREEN.sh
