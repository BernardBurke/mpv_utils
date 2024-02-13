#!/usr/bin/env bash

# read an edl file and create an mpv command that plays as a list
#source $SRC/common_inc.sh
# source $SRC/common_inc.sh
source $MPVU/util_inc.sh 
TMPFILE1=$(mktemp)

#PLAYER_FILE=$(mktemp)

convert_tdl_file_content() {
    MAX_SIZE=$(getconf ARG_MAX)
    NOMINAL_MAX=$((MAX_SIZE-100))
    ISIZE=0

    if [[ ! -f "$1" ]]; then
            message "EDL_FILE provided does not exist - $1"    
            exit 1
    else
            message "Processing $EDL_FILE"
    fi 

    if [[ ! -f "$2" ]]; then
            message "PLAYER_FILE provided does not exist - $2"    
            exit 1
    else
            PLAYER_FILE="$2"
            message "Processing $PLAYER_FILE"
    fi 


    while IFS=, read -r file start length; do
        LION="--\{ \"$file\" --start=$start --length=$length --\} \\"    
        strlen=$(echo $LION | wc -c)
        ISIZE=$((ISIZE+strlen))
        if [[ $ISIZE -gt $MAX_SIZE ]]; then
            message "command became too long $ISIZE"
            exit 1
        fi
        echo "$LION"
        echo "$LION" >> $PLAYER_FILE
    done < "$EDL_FILE"
  
    message "$1 became $ISIZE in length vs $MAX_SIZE"
}

if [[ $1 == "" ]]; then
    EDL_FILE=1
else
    if [[ -f $1 ]]; then
        EDL_FILE="$1"
    else
        message "$1 does not exit"
        exit 1
    fi
fi 

if [[ $2 == "" ]]; then
    OUTPUT_FILE=$USCR/edl2ply_$$.txt
else
    OUTPUT_FILE=$USCR/$2
fi 

cat $EDL_FILE | grep -v "#" > $TMPFILE1

message "Calling convert_edl_file_content"

convert_tdl_file_content "$EDL_FILE" "$TMPFILE1"