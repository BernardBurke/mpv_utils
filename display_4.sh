#!/bin/bash
# use nohup mpv  config profiles to cycle imaages
#source $SRC/common_inc.sh
source $MPVU/get_media.sh



if [[ "$1" = "" ]]; then
        VOLUME=0
else
        VOLUME=$1
fi

if [[ "$2" = "" ]]; then
        SCREEN=0
else
        SCREEN=$2
fi

if [[ $5 = "" ]]; then
    HOW_MANY=5
else
    HOW_MANY=$5
fi



if [[ "$3" = "edl" ]]; then
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

elif [[ "$3" = "m3u" ]]; then
        VIDEO1="$(get_file_by_type "m3u")"
        VIDEO1="--playlist=$VIDEO1 --shuffle"
        VIDEO2="$(get_file_by_type "m3u")"
        VIDEO2="--playlist=$VIDEO2 --shuffle"
        VIDEO3="$(get_file_by_type "m3u")"
        VIDEO3="--playlist=$VIDEO3 --shuffle"
        VIDEO4="$(get_file_by_type "m3u")"
        VIDEO4="--playlist=$VIDEO4 --shuffle"
        
elif [[ "$3" = "m3uSearch" ]]; then
        echo "Finding some $4"
        VIDEO1="$(get_file_by_type "m3uSearch" "$4" "$HOW_MANY")"
        VIDEO1="--playlist=$VIDEO1 --shuffle"
        VIDEO2="$(get_file_by_type "m3uSearch" "$4" "$HOW_MANY")"
        VIDEO2="--playlist=$VIDEO2 --shuffle"        
        VIDEO3="$(get_file_by_type "m3uSearch" "$4" "$HOW_MANY")"
        VIDEO3="--playlist=$VIDEO3 --shuffle"
        VIDEO4="$(get_file_by_type "m3uSearch" "$4" "$HOW_MANY")"
        VIDEO4="--playlist=$VIDEO4 --shuffle"   
elif [[ "$3" = "edlm3u" ]]; then
        TMPFILE4=$(mktemp)
        TMPFILE5=$(mktemp)
        TMPFILE6=$(mktemp)
        TMPFILE7=$(mktemp)
        get_file_by_type "edlm3u" "$4" "$HOW_MANY"
        cp $TMPFILE3 $TMPFILE4
        VIDEO1="--playlist=$TMPFILE4 --shuffle"
        get_file_by_type "edlm3u" "$4" "$HOW_MANY"
        cp $TMPFILE3 $TMPFILE5
        VIDEO2="--playlist=$TMPFILE5 --shuffle"        
        get_file_by_type "edlm3u" "$4" "$HOW_MANY"
        cp $TMPFILE3 $TMPFILE6
        VIDEO3="--playlist=$TMPFILE6 --shuffle"
        get_file_by_type "edlm3u" "$4" "$HOW_MANY"
        cp $TMPFILE3 $TMPFILE7
        VIDEO4="--playlist=$TMPFILE7 --shuffle"   
        
else
        VIDEO1="$(get_file_by_type "video")"
        VIDEO2="$(get_file_by_type "video")"
        VIDEO3="$(get_file_by_type "video")"
        VIDEO4="$(get_file_by_type "video")"

fi




echo "Playing $VIDEO1 and $VIDEO2"
#sleep 10

nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  $VIDEO1 \
        --profile=topleft  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  $VIDEO2  \
        --profile=botleft --no-border --ontop-level=system --ontop &
sleep 2

nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  $VIDEO3 \
        --profile=topright  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  $VIDEO4  \
        --profile=botright --no-border --ontop-level=system --ontop &
sleep 2

