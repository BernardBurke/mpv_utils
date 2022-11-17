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
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$1" \
        --fullscreen --no-border --ontop-level=system --ontop $
    
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

