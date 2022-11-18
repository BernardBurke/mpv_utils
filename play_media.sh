#!/bin/bash
# generic player for 1, 4, 6 (with side images)
# toDo Add subtitle and audio ala play_rx
#source $SRC/common_inc.sh
#source $MPVU/get_media.sh



play_1() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO1" \
        --fullscreen --no-border --ontop-level=system --ontop &
    
}

play_4() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO1" \
        --profile=topleft  --no-border --ontop-level=system --ontop &
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO2" \
        --profile=botleft  --no-border --ontop-level=system --ontop &
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO3" \
        --profile=topright --no-border --ontop-level=system --ontop &
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO4" \
        --profile=botright --no-border --ontop-level=system --ontop &
}

play_4_m3u() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO1" --shuffle \
        --profile=topleft  --no-border --ontop-level=system --ontop &
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO2" --shuffle \
        --profile=botleft  --no-border --ontop-level=system --ontop &
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO3" --shuffle \
        --profile=topright --no-border --ontop-level=system --ontop &
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO4" --shuffle \
        --profile=botright --no-border --ontop-level=system --ontop &
}

play_1_m3u() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    nohup  mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO1" --shuffle \
        --fullscreen --no-border --ontop-level=system --ontop &
}

play_8() {
    if [[ ! -f "$1" ]]; then
        echo "$1 does not exist"
        exit 1
    fi
    DISPLAY_TIME=15

    POSITION_ARRAY="topll toplr toprl toprr botll botlr botrl botrr"
    for geo in $POSITION_ARRAY
    do
        #nohup 
        sleep $(shuf -i 1-7 -n 1)
        nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$2 --screen=$3 --playlist="$1" --shuffle --no-border --ontop-level=system --ontop --profile=$geo &
    done

}

play_6() {
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


    DISPLAY_TIME=15

    nohup mpv --volume=$4 --screen=$5 "$1" --shuffle --no-border --ontop-level=system --ontop --profile=topmid &
    nohup mpv --volume=$4 --screen=$5 "$2" --shuffle --no-border --ontop-level=system --ontop --profile=botmid &


    POSITION_ARRAY="topll toprr botll botrr"
    for geo in $POSITION_ARRAY
    do
        #nohup 
        sleep $(shuf -i 1-7 -n 1)
        nohup mpv --image-display-duration=$DISPLAY_TIME --volume=$4 --screen=$5 --playlist="$3" --shuffle --no-border --ontop-level=system --ontop --profile=$geo &
    done

}

# read -p "Press enter to continue with $VIDEO1 $VIDEO2 $VIDEO3 $VIDEO4"

# if [[ ! -f $VIDEO2 ]]; then 
#         echo "$VIDEO2 does not exist"
#         exit 1
# fi

# if [[ ! -f $VIDEO3 ]]; then 
#         echo "$VIDEO3 does not exist"
#         exit 1
# fi

# if [[ ! -f $VIDEO4 ]]; then 
#         echo "$VIDEO4 does not exist"
#         exit 1
# fi


# cat $VIDEO2
# cat $VIDEO3
# cat $VIDEO4
#sleep 10

# nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  "$VIDEO1" \
#         --profile=topleft  --no-border --ontop-level=system --ontop &
# sleep 1
# nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  "$VIDEO2"  \
#         --profile=botleft --no-border --ontop-level=system --ontop &
# sleep 2

# nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  "$VIDEO3" \
#         --profile=topright  --no-border --ontop-level=system --ontop &
# sleep 1
# nohup mpv  --volume=$VOLUME --screen=$SCREEN --fs-screen=$SCREEN  "$VIDEO4"  \
#         --profile=botright --no-border --ontop-level=system --ontop &
# sleep 2

