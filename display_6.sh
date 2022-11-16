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



if [[ "$5" = "edl" ]]; then
        SUBJ="$(get_file_by_type "edl")"
        shuffle_edl "$SUBJ" 50
        cat $TMPFILE1 > $TMPFILE2
        VIDEO1="$TMPFILE2"
        SUBJ="$(get_file_by_type "edl")"
        shuffle_edl "$SUBJ" 50
        cat $TMPFILE1 > $TMPFILE3
        VIDEO2="$TMPFILE3"
else
        VIDEO1="$(get_file_by_type "video")"
        VIDEO2="$(get_file_by_type "video")"
fi




echo "Playing $VIDEO1 and $VIDEO2"
#sleep 10

nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  "$VIDEO1"   --profile=topmid  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  "$VIDEO2"  --profile=botmid --no-border --ontop-level=system --ontop &
sleep 2


nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=topll  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=toprr  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=botll  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  --playlist="$3" --shuffle --profile=botrr  --no-border --ontop-level=system --ontop &
