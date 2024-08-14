#!/usr/bin/env bash
# the 6 viewport method for video playlists (not just images on the edges)
#source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/play_media.sh

SCRATCH_DIR="$(mktemp -d)"

if [[ ! -f "$1" ]]; then
        echo "$1 does not exist"
        exit 1
fi
if [[ ! -f "$2" ]]; then
    echo "$2 does not exist"
    exit 1
fi

if [[ ! -f "$3" ]]; then
    echo "$3 does not exist"
    exit 1
fi

if [[ "$4" == "" ]]; then
    VOLUME=10
else
    VOLUME=$4
fi

if [[ $5 == "" ]]; then
    SCREEN=1
else
    SCREEN=$5
fi




DISPLAY_TIME=15

IS_PLAYLIST=true


if $IS_PLAYLIST
    then
        nohup mpv --volume=$VOLUME --screen=$SCREEN --playlist="$1" --shuffle --no-border --ontop-level=system --ontop --profile=topmid &
        sleep $(shuf -i 1-3 -n 1)
        nohup mpv --volume=$VOLUME --screen=$SCREEN --playlist="$2" --shuffle --no-border --ontop-level=system --ontop --profile=botmid &
    else
        nohup mpv --volume=$VOLUME --screen=$SCREEN "$1" --shuffle --no-border --ontop-level=system --ontop --profile=topmid &
        sleep $(shuf -i 1-3 -n 1)
        nohup mpv --volume=$4 --screen=$SCREEN "$2" --shuffle --no-border --ontop-level=system --ontop --profile=botmid &
fi

if $CUSTOM_SUBTITLES; then
    export IMGSUBTITLES="$CUSTOM_SUB_FILENAME"
fi 
POSITION_ARRAY="topll toprr botll botrr"
for geo in $POSITION_ARRAY
do
    #nohup 
    sleep $(shuf -i 1-7 -n 1)
    
    nohup mpv --image-display-duration=$DISPLAY_TIME --volume=10 --screen=$SCREEN --playlist="$3" --shuffle  --no-border --ontop-level=system --ontop --profile=$geo &
done
export IMGSUBTITLES=
