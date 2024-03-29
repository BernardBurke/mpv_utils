#!/usr/bin/env bash

EDL_HEADER_RECORD="# mpv EDL v0"

PREFIX="--\{*"

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
convert_playlist_to_edl() {
    local input_file="$1"
    local output_file="${input_file%.txt}.edl"
    # write the EDL_HEADER_RECORD at the beginning of the edl output file
    echo "$EDL_HEADER_RECORD" > "$output_file"
    # read the input file line by line
    while read -r pss; do
        # skip the first line if it starts with "mpv"
        if [[ "$pss" == mpv* ]]; then
            continue
        fi

        # ignore records that contain an apostrophe
        # if [[ "$pss" == *"'"* ]]; then
        #     debug_write "$pss contains an apostrophe"
        #     continue
        # fi
        # # use cut to extract the parts of the record between two braces
        audio_record=$(echo "$pss" | cut -d"{" -f2 | cut -d"}" -f1)
        #debug_write "audio_record: $audio_record"
        # if [[  "$pss" != "^$PREFIX" ]]; then
        #     debug_write "$pss does not start with $PREFIX"
        #     continue
        # fi
        # extract the full path to the audio file
        audio_file=$(echo "$pss" | cut -d'"' -f2)
        # extract the file path without the file extension.
        # this will be used to check if the audio file exists
        #debug_write "$audio_file before removing file type"
        audio_file_path=$(dirname "$audio_file")
        audio_file_extension="${audio_file##*.}"
        audio_file_name=$(basename "$audio_file" .${audio_file##*.}) || continue
        audio_file_name_only="${audio_file_path}/${audio_file_name}"
        #debug_write "$audio_file_name_only THIS ONE YOU MOTHER FUCKER $audio_file_name"
        #debug_write "audio_file_path: $audio_file_path with audio_file_extension: $audio_file_extension" 
        audio_file_full_path="$audio_file_path/$audio_file_name.$audio_file_extension"
        #debug_write "rebuilt audio file path: $audio_file_full_path"
        # only write the output_file if the audio_file exists
        if [[ ! -f "$audio_file_full_path" ]]; then
            #debug_write "audio file $audio_file_full_path does not exist - calling fixup with $audio_file_name_only"
            audio_file=$(get_audio_file "$audio_file_name_only")
            #debug_write "audio file fixup result $audio_file"
        #   else
            #debug_write "audio file $audio_file_full_path exists"
        fi
        # check if the audio file exists again
        if [[ ! -f "$audio_file" ]]; then
            debug_write "audio file $audio_file does not exist"
            continue
        fi
        
        # extract the start time and convert it to seconds
        start_time=$(echo "$pss" | cut -d'=' -f2 | cut -d'.' -f1)
        start_seconds=$(echo "$start_time" | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
        # extract the length time
        length_time=$(echo "$pss" | cut -d'=' -f3)
        length_seconds=$(echo "$length_time" | cut -d' ' -f1)
        # write the output to the output file
        echo "$audio_file,$start_seconds,$length_seconds" >> "$output_file"
    done < "$input_file"
}

# if $1 is a directory, read all the files of the name format sub_selected_audio*.txt
# and convert them to EDL format
if [[ -d "$1" ]]; then
    for file in "$1"/sub_selected_audio*.txt; do
        if [[ -f "$file" ]]; then
            debug_write "$file is being converted to EDL format"
            debug_write "$file is being converted to EDL format"
            convert_playlist_to_edl "$file"
        fi
    done
    exit
fi

if [[ ! -f "$1" ]]; then
    echo "$1 does not exist"
    exit 1
fi

if [[ ! "$1" == *.txt ]]; then
    echo "$1 is not a text file"
    exit 1
fi

convert_playlist_to_edl "$1"

# Usage: playlist2edl.sh input_file.txt

