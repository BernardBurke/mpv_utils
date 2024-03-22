#!/usr/bin/env bash

EDL_HEADER_RECORD="# mpv EDL v0"

TMPFILE1=$(mktemp)

export DEBUG=true
debug_write() {
    if [[ $DEBUG == true ]]; then
        echo "$1"
    fi
}

clean_filenames(){
    file="$1"
    BARE_NAME="$file"
    BASE_NAME=$(basename -- "$file")
    FILE_EXTENSION="${BASE_NAME##*.}"
    FILE_NAME="${BASE_NAME%.*}"
    #ALPH_NAME="${FILE_NAME//[^[:alnum:]_-]/}" 
    OUTFILENAME=$(echo $FILE_NAME | sed "s/\[.*$//g" | sed -r "s/\(.*$//g" | sed "s/\./ /g" | sed "s/  / /g")
    OUTFILENAME=$(echo $FILE_NAME | sed 's/[^a-zA-Z0-9_-]//')
    OUTFILENAME=$(echo $FILE_NAME | sed 's/[^[:alnum:]\ ]//g' | tr -s " ")
    TARGET_NAME="$OUTFILENAME.$FILE_EXTENSION"
    if [[ "$BASE_NAME" != "$TARGET_NAME" ]]; then
        echo "mv -v \"$BASE_NAME\" \"$TARGET_NAME\""
        echo "read -p \"Press return to continue\""
    fi
}

# this function takes a partial file path checks for an audio file extension
# and returns the full path to the audio file
get_audio_file() {
    local audio_file_path="$1"
    local audio_file=""
    if [[ -f "$audio_file_path".m4a ]]; then
        audio_file="$audio_file_path".m4a
    elif [[ -f "$audio_file_path".mp3 ]]; then
        audio_file="$audio_file_path".mp3
    elif [[ -f "$audio_file_path".wav ]]; then
        audio_file="$audio_file_path".wav
    elif [[ -f "$audio_file_path".flac ]]; then
        audio_file="$audio_file_path".flac
    elif [[ -f "$audio_file_path".mpga ]]; then
        audio_file="$audio_file_path".mpga
    fi
    echo "$audio_file"
}

# this function reads a .srt subtitle file and creates an MPV edl file that has
# one record per time range eg: 00:14:11,560 --> 00:14:16,560
# the start time is converted to seconds and the length is caluculated by subtracting start time from end time
# the output file is named the same as the input file but with a .edl extension
# the text from the srt file is added to the end of the edl record as a comment seperated by #
convert_srt_to_edl() {
    local input_file="$1"
    local output_file="${input_file%.srt}.edl"
    # write the EDL_HEADER_RECORD at the beginning of the edl output file
    echo "$EDL_HEADER_RECORD" > "$output_file"
    # read the input file line by line
    while read -r pss; do
        # skip the first line if it starts with "mpv"
        # if the line contains a time range
        if [[ "$pss" == *"-->"* ]]; then
            # extract the start and end time
            start_time=$(echo "$pss" | cut -d' ' -f1)
            end_time=$(echo "$pss" | cut -d' ' -f3)
            # convert the start time to seconds
            start_seconds=$(echo "$start_time" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
            # calculate the length by subtracting start time from end time
            length=$(echo "$end_time" | awk -F: '{ print (($1 * 3600) + ($2 * 60) + $3) - '"$start_seconds"' }')
            # write the edl record to the output file
            record="$2,$start_seconds,$length #" # $pss" #>> "$output_file"
        else
            # write the text from the srt file as a comment
            #echo "# $pss" #>> "$output_file"
            record="${record} ${pss}"
        fi
        echo "$record" >> $TMPFILE1
    done < "$input_file"
}

# check if the input file exists
if [[ ! -f "$1" ]]; then
    echo "$1 does not exist"
    exit 1
fi

audio_file_without_extension=$(basename "$1" .srt)
audio_file_without_extension="$(dirname "$1")/$audio_file_without_extension"

audio_file=$(get_audio_file "$audio_file_without_extension")

edl_file="${audio_file_without_extension}.edl"

echo $EDL_HEADER_RECORD > "$edl_file"


convert_srt_to_edl "$1" "$audio_file"

cat $TMPFILE1 >> "$edl_file"

cat "$edl_file"