#!/bin/bash
# read an edl file and create an mpv command that plays as a list
#source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

#PLAYER_FILE=$(mktemp)

if [[ $1 == "" ]]; then
    PLAY_MODE=1
else
    PLAY_MODE=$1
fi 

if [[ $2 == "" ]]; then
    VOLUME=0
else
    VOLUME=$2
fi 




if [[ $3 == "" ]]; then
    SCREEN=0
else
    SCREEN=$3
fi 

if [[ $4 == "" ]]; then
    SEARCH_EDLS=false
else
    SEARCH_EDLS=true
    EDL_SEARCH_STRING="$4"
fi

if [[ $5 == "" ]]; then
    DIRECTORY_NAME="$HANDUNI"
else
    if [[ -d "$5" ]]; then
        DIRECTORY_NAME="$5"
    else
        "$5 provided directory does not exist"
        exit 1
    fi
fi

get_subject(){

        if $SEARCH_EDLS ; then
            FILE="$(find $DIRECTORY_NAME/ -iname '*.edl' | grep -i "$EDL_SEARCH_STRING" | shuf -n 1)"
            if [[ ! -f $FILE ]]; then
                message "get_subject Searching for an EDL didn't return any results with $EDL_SEARCH_STRING"
                exit 1
            else
                message "SEARCH_EDLS found $FILE using $EDL_SEARCH_STRING"
            fi
        else
            FILE="$(find $DIRECTORY_NAME/ -iname '*.edl' | grep -iv movie | grep -iv tv | shuf -n 1)"
        fi

        if $DEBUG_PAUSE ; then
            message "Pre validate_edl"
            cat "$FILE"
            read -p "Press Return to continue"
        fi


        if validate_edl "$FILE"; then
            message "Valid EDL file $FILE"
        else
            message "invalid file $FILE"
            exit 1
        fi
        if $DEBUG_PAUSE ; then
            message "Post validate_edl"
            cat "$FILE"
            read -p "Press Return to continue"
        fi

}

edl_playlist_6(){
    pfiles=(
        PLAYER_FILE1 
        PLAYER_FILE2 
    )
    geos=(
        topmid
        botmid 
    )
    for  indx in ${!pfiles[*]}; do
        echo $indx
        echo "${pfiles[$indx]} and ${geos[$indx]} "
        get_subject
        # ${pfiles[$indx]}=$(mktemp)
        # ls $PLAYER_FILE1
        convert_edl_file "$FILE" "${pfiles[$indx]}" $SCREEN "${geos[$indx]}"
        cat ${pfiles[$indx]} > /tmp/command_list_edl_playlist.log

    done

    # read -p "Press Return to continue"

    for indx in ${!pfiles[*]} ; do
            cp "${pfiles[$indx]}" /tmp/$indx.sh
            bash -x "${pfiles[$indx]}" &
    done

    DISPLAY_TIME=15
    TMPFILE1=$(mktemp)

    IMAGE_ARRAY="newmaisey slices ten9a darina cheeky gallery-dl handpinned"

    for folder in $IMAGE_ARRAY
    do 
          find /mnt/d/grls/images2/$folder -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.png' -o -iname '*.gif' | shuf -n 1000 >> $TMPFILE1
    done

    
    POSITION_ARRAY="topll toprr botll botrr"
    for geo in $POSITION_ARRAY
    do
        #nohup 
        sleep $(shuf -i 1-3 -n 1)
        command="nohup mpv --image-display-duration=$DISPLAY_TIME --volume=10 --screen=$SCREEN --playlist=$TMPFILE1 --shuffle  --no-border --ontop-level=system --ontop --profile=$geo"
        echo $command
        $command &
         
    done

}


edl_playlist_4(){
    pfiles=(
        PLAYER_FILE1 
        PLAYER_FILE2 
        PLAYER_FILE3 
        PLAYER_FILE4
    )
    geos=(
        topleft 
        topright 
        botleft 
        botright
    )
    for  indx in ${!pfiles[*]}; do
        echo $indx
        echo "${pfiles[$indx]} and ${geos[$indx]} "
        get_subject
        # ${pfiles[$indx]}=$(mktemp)
        # ls $PLAYER_FILE1
        convert_edl_file "$FILE" "${pfiles[$indx]}" $SCREEN "${geos[$indx]}"
        cat ${pfiles[$indx]} > /tmp/command_list_edl_playlist.log

    done

    if $DEBUG_PAUSE ; then
        read -p "Press Return to continue"
    fi

    for indx in ${!pfiles[*]} ; do
            cp "${pfiles[$indx]}" /tmp/$indx.sh
            bash -x "${pfiles[$indx]}" &
    done
}


edl_playlist_1(){

    PLAYER_FILE1=$(mktemp)
    get_subject
    convert_edl_file "$FILE" "$PLAYER_FILE1" $SCREEN "override"
    cat "$PLAYER_FILE1" > /tmp/command_list_edl_playlist.log

    if $DEBUG_PAUSE ; then
        read -p "Press Return to continue"
    fi

    cp $PLAYER_FILE1 /tmp/1.sh
    bash -x "$PLAYER_FILE1" &

}

case "$PLAY_MODE" in
        "1")
        edl_playlist_1
        ;;
        "4")
        edl_playlist_4
        ;;
        "6")
        edl_playlist_6
        ;;
        *)
        message "Invalid play_media code $PLAY_MODE";;
esac

echo "running..."
echo ""

# convert_edl_file(){
#     if [[ ! -f "$1" ]]; then
#     message "$1 does not exist"
#     exit 1
# else
#     message "Processing  $1"
#     EDL_FILE=$(mktemp)
#     cat "$1" | grep -v "#" > $EDL_FILE
# fi 

# echo "mpv --screen=0 \\" > $PLAYER_FILE
# # toDo - validate
# # validate edl "$EDL_FILE"

# while IFS=, read -r file start length; do
#     echo "--\{ \"$file\" --start=$start --length=$length --\} \\" >> $PLAYER_FILE
# done < "$EDL_FILE"

# }


# convert_seconds(){
#     message "Converting seconds"
# }
# FILE="$(find $HANDUNI/ -iname '*.edl' | shuf -n 1)"
# convert_edl_file "$FILE" "" $SCREEN "topleft"
# message "Player File is $PLAYER_FILE"
# bash -x $PLAYER_FILE &




