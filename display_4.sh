#!/bin/bash
# use nohup mpv --image-display-duration=$DISPLAY_TIME config profiles to cycle imaages
source $SRC/common_inc.sh

if [[ ! -d "$3" ]]; then
    echo "Please provice a directory file that exists"
    exit 1
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

if [[ ! -f "$5" ]]; then
        VIDEO1="$(find /mnt/d/edlv2/ -iname '*shaken*.edl' | grep unix | shuf -n 1)"
else
        VIDEO1="$5"
fi

if [[ ! -f "$6" ]]; then
        VIDEO2="$(find /mnt/d/edlv2/ -iname '*shaken*.edl' | grep unix | shuf -n 1)"
else
        VIDEO2="$6"
fi

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
