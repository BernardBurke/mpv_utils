#!/usr/bin/env bash

#source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"

# this function takes a single grep search string and searches $AUDEY and $AUDEY2 for files containing the string
# It then presents the matching file paths using the select command
# The user can then choose one of the files or cancel the selection
# The function returns the selected file path or an empty string if the user cancels the selection

function pick_file() {
    TMPFILE1=$(mktemp)
    search_string=$1
    find $AUDEY $AUDEY2 -iname "*$search_string*.srt" > $TMPFILE1
    if [[ "$(wc -l $TMPFILE1)" == 0 ]]; then
        echo "No files found in $AUDEY or $AUDEY2 matching $search_string"
        return
    fi
    PS3="Choose one of the following files: "
    #oldIFS=$IFS # Save the current value of IFS
    #IFS=$'\n' # Set the Internal Field Separator to newline to handle file names with spaces
    dialog --menu "Choose one of the following files:" 0 0 0 $TMPFILE1 "Cancel" 2>/tmp/dialog_output
    choice=$(cat /tmp/dialog_output)
    rm /tmp/dialog_output
    if [[ "$choice" == "Cancel" ]]; then
        #IFS=$oldIFS # Restore the original value of IFS
        return
    fi
    if [[ -z "$choice" ]]; then
        echo "Invalid selection"
        return
    fi
    echo "$choice"
    #IFS=$oldIFS # Restore the original value of IFS
    #return
    #done
}

# this function searches all the .srt files in $AUDEY and $AUDEY2 for the search string passed as $1

# First, check that the search strings are passed as parameters $1 and $2
if [[ "$1" == "" ]]; then
    echo "Usage: $0 search_string1"
    exit 1
fi  

echo "$(pick_file "$1")"