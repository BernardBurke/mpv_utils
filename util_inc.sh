#!/bin/bash
# general purpose functions 
logmessage() {
    LOG_FILE="/tmp/mpv_utlities.log"
    echo "$1" >> "$LOG_FILE"
}

message() {
    SCRIPT_NAME="$(basename "$0" .sh)";
    MESSAGE_TEXT="$SCRIPT_NAME "$1" "$2" "$3" "$4" "$5" "$6""
    echo "$MESSAGE_TEXT"
    logmessage "$MESSAGE_TEXT"
}

get_random_subtitles() {
    echo "$(find /mnt/d/grls/audio/ \( -iname '*.srt' -o -iname '*.vtt' \) -exec grep -il "$1" {} \; | shuf -n 1)"
}

get_random_edl_content() {
   echo "$(find /mnt/d/edlv2  -iname '*.edl' -exec grep -il "$1" "{}" \; | grep -iv windows | shuf -n 1)"
}

get_random_edl_file() {
   RESALT="$(find /mnt/d/edlv2  -iname "*$1*.edl"  | grep -iv windows | shuf -n 1)"
   if [[ "$RESALT" == "" ]]; then
        #echo  "file not found in get_random_edl_file"
        exit 1
    fi 
    echo "$RESALT"
}

get_random_video() {
    echo "$(find /mnt/d/grls -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.wmv' |   shuf -n 1)"
}


get_length(){
    if [[ ! -f "$1" ]]; then
        echo "0"
        exit 1
    fi
    LNGTH=$(ffprobe -v quiet  -of csv=p=0 -show_entries format=duration "$1")
    LNGTH=${LNGTH%.*}
    echo "$LNGTH"
}

function minimum_length (){
    if [[ "$2" == "" ]]; then
        MINI=300
    else
        MINI=$2
    fi

    LENGTH="$(get_length "$1")"
    if (( LENGTH < MINI)) ; then
            return 1
        else
            return 0
    fi 
}


validate_edl() {
    EDL_FILE="$1"
    ANY_PROBLEMS=false
    EDL_FILE_ONLY="$(basename "$EDL_FILE")"
    TMP_EDL_DIR=$(mktemp -d)
    #TMP_EDL_DIR=/tmp
    message "$TMP_EDL_DIR is the correction directory"
    TMP_EDL_FILE="$TMP_EDL_DIR/$EDL_FILE_ONLY"
    #read -p "Press Return to continue with $EDL_FILE"
    if [[ ! -f "$EDL_FILE" ]]; then
        echo "${EDL_FILE} does not exist"
        return 1
    fi

    SAVED_IFS="$IFS"

    while IFS=, read -r line start end; do
        if [[ ${line::1} != "#" ]]; then
            if [[ ! -f "$line" ]]; then
                ANY_PROBLEMS=true
                message "$line does not exist"
                echo "# $line" >> "$TMP_EDL_FILE"
            elif [[ "$start" == "" ]]; then
                ANY_PROBLEMS=true
                message "invalid start time in $EDL_FILE on line $line"
                echo "# $line" >> "$TMP_EDL_FILE"
            elif [[ "$end" == "" ]]; then
                ANY_PROBLEMS=true
                message "invalid start time"
                echo "# $line" >> "$TMP_EDL_FILE"
            else
                echo "$line,$start,$end" >> "$TMP_EDL_FILE"
            fi 
        else
            echo "$line" >> "$TMP_EDL_FILE"
        fi 
    done < "$EDL_FILE"

    message "The temp EDL directory is $TMP_EDL_DIR"

    if $ANY_PROBLEMS; then
        message "$EDL_FILE had problems. A corrected version written as $TMP_EDL_FILE"
        exit 1
    else
        rm -v "$TMP_EDL_FILE"
        echo "no problems in $TMP_EDL_FILE"
    fi 

}

convert_edl_file_content() {
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
        echo "$LION" >> $PLAYER_FILE
    done < "$EDL_FILE"
  
    message "$1 became $ISIZE in length vs $MAX_SIZE"
}


convert_edl_file(){
    if [[ ! -f "$1" ]]; then
        message "$1 does not exist"
        exit 1
    else
        message "Processing  $1"
        if [[ "$2" == "" ]];then
            PLAYER_FILE=$(mktemp)
        else
            PLAYER_FILE="$2"
        fi
        EDL_FILE=$(mktemp)
        cat "$1" | grep -v "#" > $EDL_FILE
    fi 

    if [[ $3 == "" ]];then
        SCREEN=0
    else
        SCREEN=$3
    fi

    if [[ $4 == "" ]];then
        echo "nohup mpv --screen=$SCREEN \\" > $PLAYER_FILE
    else
        echo "nohup mpv --screen=$SCREEN --profile=$4 \\" > $PLAYER_FILE
    fi 


    # toDo - validate
    # validate edl "$EDL_FILE"
    convert_edl_file_content "$1" $PLAYER_FILE
    # while IFS=, read -r file start length; do
    #     echo "--\{ \"$file\" --start=$start --length=$length --\} \\" >> $PLAYER_FILE
    # done < "$EDL_FILE"

}




