#!/bin/bash
# use nohup mpv --image-display-duration=$DISPLAY_TIME config profiles to cycle imaages
#source $SRC/common_inc.sh
source $MPVU/get_media.sh

if [[ ! -d "$3" ]]; then
        if [[ ! -f "$3" ]]; then
                echo "Please provice a file or directory that exists"
                exit 1
        fi 
fi

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

if [[ $4 = "" ]]; then
    DISPLAY_TIME=5
else
    DISPLAY_TIME=$4
fi

read -p "Press enter to continue with $5"


if [[ "$5" = "edl" ]]; then
        SUBJ="$(get_file_by_type "edl")"
        shuffle_edl "$SUBJ" 50
        cat $TMPFILE1 > $TMPFILE2
        VIDEO1="$TMPFILE2"
        SUBJ="$(get_file_by_type "edl")"
        shuffle_edl "$SUBJ" 50
        cat $TMPFILE1 > $TMPFILE3
        VIDEO2="$TMPFILE3"
elif [[ "$5" = "m3u" ]]; then
        VIDEO1="$(get_file_by_type "m3u")"
        echo "$VIDEO1"
        VIDEO1="--playlist=$VIDEO1 --shuffle"
        VIDEO2="$(get_file_by_type "m3u")"
        VIDEO2="--playlist=$VIDEO2 --shuffle"
elif [[ "$5" = "m3uSearch" ]]; then
        TMPFILE4=$(mktemp)
        TMPFILE5=$(mktemp)
        echo "Finding some $6"
        VIDEO1="$(get_file_by_type "m3uSearch" "$6" "$7")"
        cp -v "$TMPFILE3" "$TMPFILE4"
        VIDEO1="--playlist=$TMPFILE4 --shuffle"
        VIDEO2="$(get_file_by_type "m3uSearch" "$6" "$7")"
        cp -v "$TMPFILE3" "$TMPFILE5"
        VIDEO2="--playlist=$TMPFILE5 --shuffle"        
elif [[ "$5" = "edlm3u" ]]; then
        TMPFILE4=$(mktemp)
        TMPFILE5=$(mktemp)
        echo "Finding some $6"
        VIDEO1="$(get_file_by_type "edlm3u" "$6" "$7")"
        cp -v "$TMPFILE3" "$TMPFILE4"
        VIDEO1="--playlist=$TMPFILE4 --shuffle"
        VIDEO2="$(get_file_by_type "edlm3u" "$6" "$7")"
        cp -v "$TMPFILE3" "$TMPFILE5"
        VIDEO2="--playlist=$TMPFILE5 --shuffle"                
else
        VIDEO1="$(get_file_by_type "video")"
        VIDEO2="$(get_file_by_type "video")"
fi


read -p "Press enter to continue with $VIDEO1 $VIDEO2"

echo "Playing $VIDEO1 and $VIDEO2"
#sleep 10

nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  $VIDEO1 --profile=topmid  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  $VIDEO2  --profile=botmid --no-border --ontop-level=system --ontop &
sleep 2

echo "Playing $VIDEO1 and $VIDEO2"

nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=topll  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=toprr  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=botll  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=botrr  --no-border --ontop-level=system --ontop &
