#!/usr/bin/env bash

# this script takes a filepath, a filter string (iname for find)

# It then creates a list for zenity to allow the user to select a file
# and play that file using mpv
# The zenity menu stays open while playing the file
# The user can select another file to play while the first file is playing

# check for a valid path in $1
if [[ "$1" == "" ]]; then
    echo "Usage: $0 directory"
    exit 1
fi

TMPFILE1="$(mktemp)"


# if $1 is an m3u file, use the contents of the m3u file as the list of files
if [[ "$1" == *.m3u ]]; then
    cat "$1" > $TMPFILE1
    M3U_MODE=true
else
    M3U_MODE=false
    # check that the directory pointed to by $1 exists
    if [[ ! -d "$1" ]]; then
        echo "Directory $1 does not exist"
        exit 1
    fi
fi


# if M3U_MODE is false
if ! $M3U_MODE; then
    # get the iname filter from $2
    if [[ "$2" == "" ]]; then
        NO_FILTER=true
        find "$1" -type f -print0 > $TMPFILE1
    else
        NO_FILTER=false
        FILTER="$2"
        find "$1" -type f -iname "*$FILTER*" -print0 > $TMPFILE1
    fi
fi

SCREEN=0


# use zenity to display the list of files in $TMPFILE1 and let the user pick one
# the user can also cancel the selection

# zenity will return the selected file or nothing if the user cancels
# the selected file will be passed to mpv for playing
while true; do
    FILE=$(cat $TMPFILE1 | zenity --list --column="Files" --text="Select a file to play" --width=800 --height=600)
    if [[ "$FILE" == "" ]]; then
        break
    fi
    mpv --screen=$SCREEN "$FILE"
    # remove the $FILE record from $TMPFILE1
    FILE_ESCAPED=$(echo "$FILE" | sed 's/\//\\\//g')
    sed -i "/$FILE_ESCAPED/d" $TMPFILE1
done