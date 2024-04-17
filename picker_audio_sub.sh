#!/usr/bin/env bash

#source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"


# First, check that the search strings are passed as parameters $1 and $2
    if [[ "$1" == "" ]]; then
        echo "Usage: $0 search_string1"
        exit 1
    fi  


    TMPFILE1=$(mktemp)
    search_string=$1
    oldIFS=$IFS # Save the current value of IFS
    choice="$(find $AUDEY $AUDEY2 -iname '*.srt' -exec grep -il "$1" "{}" \; | zenity --list --column="Files" --title="Select an SRT file" --text="Choose one of the following files" --width=800 --height=600 )"
    if [[ "$(wc -l $TMPFILE1)" == 0 ]]; then
        echo "No files found in $AUDEY or $AUDEY2 matching $search_string"
        exit 1
    fi
    PS3="Choose one of the following files: "
    if [[ "$choice" == "Cancel" ]]; then
        return
    fi
    if [[ -z "$choice" ]]; then
        echo "Invalid selection"
        exit 1
    fi
    IFS=$oldIFS # Restore the original value of IFS
    echo "$choice"


