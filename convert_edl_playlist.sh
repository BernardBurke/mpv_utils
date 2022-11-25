#!/bin/bash
# read an edl file and create an mpv command that plays as a list
#source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

#PLAYER_FILE=$(mktemp)

if [[ $1 == "" ]]; then
    SCREEN=0
else
    SCREEN=$1
fi 

if [[ $2 == "" ]]; then
    DIRECTORY_NAME="$HANDUNI"
else
    if [[ -d "$2" ]]; then
        DIRECTORY_NAME="$2"
    else
        "$2 provided directory does not exist"
        exit 1
    fi
fi

get_subject(){

        FILE="$(find $DIRECTORY_NAME/ -iname '*.edl' | grep -vi movie | grep -vi tv | shuf -n 1)"
        if validate_edl "$FILE"; then
            message "Valid EDL file $FILE"
        else
            message "invalid file $FILE"
            exit 1
        fi
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

    read -p "Press Return to continue"

    for indx in ${!pfiles[*]} ; do
                bash -x "${pfiles[$indx]}" &
    done
}

edl_playlist_4
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




