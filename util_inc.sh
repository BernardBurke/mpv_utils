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