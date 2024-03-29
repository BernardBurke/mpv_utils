#!/usr/bin/env bash
# generic player for 1, 4, 6 (with side images)
# toDo Add subtitle and audio ala play_rx
#source $SRC/common_inc.sh
#source $MPVU/get_media.sh
source $MPVU/util_inc.sh

random_subtitles() {
    if $SUPPRESS_SUBTITLES; then
        echo ""
        return 0
    fi 
    if $RANDOM_SUBTITLES; then
        echo "$(find $AUDEY/ -iname '*.txt' | shuf -n 1)"
    else
        echo ""
    fi
}



play_1() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO1" \
        --fullscreen --no-border --ontop-level=system --ontop &
    export IMGSUBTITLES=
}

play_1_subs() {
#   pass in just the subtitle filename and derive the audio from it

    if [[ ! -f "$1" ]]; then 
        echo "play_1_subs called with P1 $1 does not exist"
        exit 1
    fi
    
    DIRECTORY=$(dirname "$2")

    tmpfilename1="$DIRECTORY/$(basename "$2" srt)mp3"
    tmpfilename2="$DIRECTORY/$(basename "$2" srt)m4a"
    tmpfilename3="$DIRECTORY/$(basename "$2" srt)wav"
    tmpfilename4="$DIRECTORY/$(basename "$2" srt)mpga"
    #toDo- include mpga
    
    if [[ -f "$tmpfilename1" ]]; then
        AUDIO_FILENAME="$tmpfilename1"
    elif [[ -f "$tmpfilename2" ]]; then
        AUDIO_FILENAME="$tmpfilename2"
    elif [[ -f "$tmpfilename3" ]]; then
        AUDIO_FILENAME="$tmpfilename3"
    elif [[ -f "$tmpfilename4" ]]; then
        AUDIO_FILENAME="$tmpfilename4"
    else
        echo "No audio file found for $2"
        exit 1
    fi

    echo "using $AUDIO_FILENAME"

    if $IS_PLAYLIST;then
            mpv_command1="nohup mpv  --volume=$3 --screen=$4 --fs-screen=$4  --playlist=\"$1\" --shuffle  "
    else
            mpv_command1="nohup mpv  --volume=$3 --screen=$4 --fs-screen=$4  \"$1\" --shuffle  "
    fi
    
    # add the rest of the command
    mpv_command1="${mpv_command1} --fullscreen --no-border --ontop-level=system --ontop  "
    mpv_command1="${mpv_command1} --sub-files-add=\"$2\" --audio-files-add=\"$AUDIO_FILENAME\"  "

    message "mpv_command1 is $mpv_command1"
    RUNFILE=/tmp/rx_cmd_$4.$$
    echo "$mpv_command1" > $RUNFILE

    bash $RUNFILE &
# if $IS_PLAYLIST; then
#     nohup mpv  --volume=$3 --screen=$4 --fs-screen=$4  --playlist="$1" --shuffle \
#         --fullscreen --no-border --ontop-level=system --ontop \
#         --sub-files-add="$2" --audio-files-add="$AUDIO_FILENAME"  &
# else
#     nohup mpv  --volume=$3 --screen=$4 --fs-screen=$4  "$1" --shuffle \
#         --fullscreen --no-border --ontop-level=system --ontop \
#         --sub-files-add="$2" --audio-files-add="$AUDIO_FILENAME"  &

# fi  
}

play_4_validate() {

    if ! validate_edl $VIDEO1; then exit 1 ; fi
    if ! validate_edl $VIDEO2; then exit 1 ; fi
    if ! validate_edl $VIDEO3; then exit 1 ; fi
    if ! validate_edl $VIDEO4; then exit 1 ; fi

}

play_4() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    if [[ PLAY_MODE == "edlblend" ]]; then
        play_4_validate
    fi
    message "in play_4"
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO1" \
       --profile=topleft  --no-border --ontop-level=system --ontop --log-file=/tmp/VIDEO1.log &
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO2" \
       --profile=botleft  --no-border --ontop-level=system --ontop --log-file=/tmp/VIDEO2.log &
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO3" \
       --profile=topright --no-border --ontop-level=system --ontop --log-file=/tmp/VIDEO3.log &
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3  "$VIDEO4" \
       --profile=botright --no-border --ontop-level=system --ontop --log-file=/tmp/VIDEO4.log &
}

play_4_m3u() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    #play_4_validate
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO1" --shuffle --log-file=/tmp/VIDEO1.log \
       --profile=topleft  --no-border --ontop-level=system --ontop &
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO2" --shuffle --log-file=/tmp/VIDEO2.log \
       --profile=botleft  --no-border --ontop-level=system --ontop &
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO3" --shuffle --log-file=/tmp/VIDEO3.log \
       --profile=topright --no-border --ontop-level=system --ontop &
    export IMGSUBTITLES="$(random_subtitles)"
    nohup mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO4" --shuffle --log-file=/tmp/VIDEO4.log \
       --profile=botright --no-border --ontop-level=system --ontop &
}

play_1_m3u() {
    if [[ ! -f "$1" ]]; then 
        echo "$1 does not exist"
        exit 1
    fi
    nohup  mpv  --volume=$2 --screen=$3 --fs-screen=$3 --playlist="$VIDEO1" --shuffle \
       --script=$MPVU/dbx.lua --fullscreen --no-border --ontop-level=system --ontop &
}

play_8() {
    if [[ ! -f "$1" ]]; then
        echo "$1 does not exist"
        exit 1
    fi
    DISPLAY_TIME=5

    if $CUSTOM_SUBTITLES; then
        export IMGSUBTITLES="$CUSTOM_SUB_FILENAME"
    fi 
    POSITION_ARRAY="topll toplr toprl toprr botll botlr botrl botrr"
    echo "Don't worry - we're randomising the start times"
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

    if $IS_PLAYLIST
        then
            nohup mpv --volume=$4 --screen=$5 --playlist="$1" --shuffle --no-border --ontop-level=system --ontop --profile=topmid &
            sleep $(shuf -i 1-3 -n 1)
            nohup mpv --volume=$4 --screen=$5 --playlist="$2" --shuffle --no-border --ontop-level=system --ontop --profile=botmid &
        else
            nohup mpv --volume=$4 --screen=$5 "$1" --shuffle --no-border --ontop-level=system --ontop --profile=topmid &
            sleep $(shuf -i 1-3 -n 1)
            nohup mpv --volume=$4 --screen=$5 "$2" --shuffle --no-border --ontop-level=system --ontop --profile=botmid &
    fi

    if $CUSTOM_SUBTITLES; then
        export IMGSUBTITLES="$CUSTOM_SUB_FILENAME"
    fi 
    POSITION_ARRAY="topll toprr botll botrr"
    for geo in $POSITION_ARRAY
    do
        #nohup 
        sleep $(shuf -i 1-7 -n 1)
        
        nohup mpv --image-display-duration=$DISPLAY_TIME --volume=10 --screen=$5 --playlist="$3" --shuffle  --no-border --ontop-level=system --ontop --profile=$geo &
    done
    export IMGSUBTITLES=
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

