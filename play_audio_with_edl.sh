#!/usr/bin/env bash
source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"

# This script is given an audio file $1 and an edl file $2.
# First we get the length of the audio file using get_length() $1
# First check parameters
if [[ "$1" == "" || "$2" == "" ]]; then
    echo "Usage: $0 audio_file edl_file"
    exit 1
fi
# check that the audio file exists and the edl file exists
if [[ ! -f "$1" ]]; then
    echo "$1 does not exist"
    exit 1
fi
if [[ ! -f "$2" ]]; then
    echo "$2 does not exist"
    exit 1
fi

# get the SCREEN and VOLUME as $3 and $4 (or default to 0 and 10)
if [[ "$3" != "" ]]; then
    SCREEN=$3
else
    SCREEN=2
fi
if [[ "$4" != "" ]]; then
    VOLUME=$4
else
    VOLUME=10
fi

get_edl_of_total_length() {
    if [[ ! -f "$1" ]]; then
        echo "get_edl_of_total_length: $1 does not exist"
        exit 1
    fi

    if [[ -z "$2" ]]; then  # Check for empty string using -z
        echo "get_edl_of_total_length: no length provided"
        exit 1
    fi

    if [[ -z "$3" ]]; then  # Check for empty string using -z
        echo "get_edl_of_total_length: no output file provided"
        exit 1
    fi


    echo "get_edl_of_total_length: $1 $2"

    # Create temporary file if it doesn't exist
    TMPFILE1=$(mktemp)

    EDL_FILE="$1"
    TOTAL_LENGTH="$2"

    echo "shuffling to $TMPFILE1"

    cat "$EDL_FILE" | shuf -n 1000 > "$TMPFILE1"  # Quote variables for file paths
    EDL_TOTAL_LENGTH=0

    # Read temporary file line by line. Ignore lines starting with #
    while IFS=, read -r file start length; do
        if [[ "$file" == \#* ]]; then 
            continue
        fi

        echo "file: $file start: $start length: $length"
        EDL_TOTAL_LENGTH=$((EDL_TOTAL_LENGTH + length))
        echo "EDL_TOTAL_LENGTH: $EDL_TOTAL_LENGTH"

        # Check if EDL_TOTAL_LENGTH is greater than TOTAL_LENGTH
        if (( EDL_TOTAL_LENGTH > TOTAL_LENGTH )); then
            echo "EDL_TOTAL_LENGTH $EDL_TOTAL_LENGTH is greater than TOTAL_LENGTH $TOTAL_LENGTH"
            break
        fi

        # Write the line to the output file
        echo "$file,$start,$length" >> "$3"
    done < "$TMPFILE1"

    # Remove the temporary file
    rm "$TMPFILE1"

    echo "EDL_TOTAL_LENGTH: $EDL_TOTAL_LENGTH"
}

# get the length of the audio file
LENGTH=$(get_length "$1")
echo "LENGTH: $LENGTH"
#get_edl_of_total_length "$2" "$LENGTH"

NEW_EDL=$(mktemp)
echo $EDL_HEADER_RECORD > $NEW_EDL

#NEW_EDL=$(get_edl_of_total_length "$2" "$LENGTH")
get_edl_of_total_length "$2" "$LENGTH" "$NEW_EDL"
cat $NEW_EDL

read -p "Press enter to continue"

SRT_FILE=$(echo "$1" | sed 's/\(.*\)\..*/\1.srt/')
audio_file="$1"

runfile="/tmp/mpv_commands_$$.sh"
echo "runfile: $runfile"


echo mpv --sub-file="\"$SRT_FILE"\" --fullscreen --fs-screen=$SCREEN --audio-file="\"$audio_file"\" --screen=$SCREEN --volume=$VOLUME ""$NEW_EDL""    > $runfile

cat $runfile
nohup bash $runfile & 


# we call get_edl_of_total_length to get a new edl file that is a random selection of the edl file