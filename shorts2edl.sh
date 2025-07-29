#!/usr/bin/env bash
source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"


# this script takes a single argument, a directory fill of short video files
# we will use the get_length() function to get the length of each file
# then write an edl file, using a start of 0 and the length of the file
# the output is written to the provided directory as shorts.edl
# the output is also written to the screen

# First check parameters
if [[ "$1" == "" ]]; then
    echo "Usage: $0 directory"
    exit 1
fi

# if the first parameter is file, do the same logic as the find below, except wit the contents of the file in $1
# Check that each record in the file is a valid video file too
if [[ -f "$1" ]]; then
    echo "Processing file $1"
    OUTPUT_FILE="/tmp/shorts.edl"
    echo "$EDL_HEADER_RECORD" > $OUTPUT_FILE

    TOTAL_LINES=$(grep -cve '^\s*$' "$1")
    if [[ $TOTAL_LINES -eq 0 ]]; then
        echo "No files to process."
        exit 1
    fi

    COUNT=0
    NEXT_PERCENT=10

    while read -r file; do
        [[ -z "$file" ]] && continue
        ((COUNT++))
        if [[ -f "$file" ]]; then
            LENGTH=$(get_length "$file")
            echo "$file, 0, $LENGTH" >> $OUTPUT_FILE
        else
            echo "Skipping invalid file: $file"
        fi

        PERCENT=$((COUNT * 100 / TOTAL_LINES))
        if [[ $PERCENT -ge $NEXT_PERCENT ]]; then
            echo "$PERCENT% complete"
            NEXT_PERCENT=$((NEXT_PERCENT + 10))
        fi
    done < "$1"
    echo "EDL written to $OUTPUT_FILE"
    exit 0
fi

# check that the directory exists
if [[ ! -d "$1" ]]; then
    echo "$1 does not exist"
    exit 1
fi

# get the SCREEN and VOLUME as $2 and $3 (or default to 2 and 10)
if [[ "$2" != "" ]]; then
    SCREEN=$2
else
    SCREEN=2
fi
if [[ "$3" != "" ]]; then
    VOLUME=$3
else
    VOLUME=10
fi


# write the output into $1/shorts.edl
OUTPUT_FILE="$1/shorts.edl"
echo "$EDL_HEADER_RECORD" > $OUTPUT_FILE

find "$1" -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.webm" -o -iname "*.mkv" -o -iname "*.gif" \) | while read -r file; do
    echo "Processing $file"
    LENGTH=$(get_length "$file")
    echo "$file, 0, $LENGTH" >> $OUTPUT_FILE
done
