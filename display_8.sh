#!/usr/bin/env bash
# use nohup mpv --image-display-duration=$DISPLAY_TIME config profiles to cycle imaages
source $SRC/common_inc.sh

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

nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=topll  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=toplr  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=toprl  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=toprr  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=botll  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=botlr  --no-border --ontop-level=system --ontop &
sleep 1
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=botrl  --no-border --ontop-level=system --ontop &
sleep 2
nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  \
--playlist="$3" --shuffle --profile=botrr  --no-border --ontop-level=system --ontop &
