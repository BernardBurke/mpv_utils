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

for file in $1/*.mp4 $1/*.avi $1/*.webm $1/*.mkv $1/*.gif; do
    if [[ -f "$file" ]]; then
        echo "Processing $file"
        LENGTH=$(get_length "$file")

        echo "$file, 0, $LENGTH" >> $OUTPUT_FILE
    fi
done
