#!/bin/bash
# written to validate EDL files, but no doubt will have other functions.

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

validate_edl() {
    EDL_FILE="$1"
    ANY_PROBLEMS=false
    EDL_FILE_ONLY="$(basename "$EDL_FILE")"
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
            elif [[ "$start" =="" ]]; then
                ANY_PROBLEMS=true
                message "invalid start time"
                echo "# $line" >> "$TMP_EDL_FILE"
            elif [[ "$end" =="" ]]; then
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
        return 1
    else
        rm -v "$TMP_EDL_FILE"
        #echo "no problems in $TMP_EDL_FILE"
    fi 

}


if ! validate_edl "$1"; then
    message " is not valid"
fi

#message "Were is Beeps" "I cannot find him "