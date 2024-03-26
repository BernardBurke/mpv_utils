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
    # write the EDL_HEADER_RECORD at the beginning of the edl output file
    echo "$EDL_HEADER_RECORD" > "$TMPFILE1"
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
            # spice things up by subtracting 2 seconds from the start time and adding 5 seconds to the length
            start_seconds=$(echo "$start_seconds - 2" | bc)
            length=$(echo "$length + 5" | bc)
            previous_record="$2,$start_seconds,$length" 
        else
                echo "#${pss}" >> $TMPFILE1
                echo $previous_record >> $TMPFILE1
        fi
    done < "$input_file"
}


# if $1 is a directory, use find to get all the .srt files in the directory and subdirectorys
if [[ -d "$1" ]]; then
    find "$1" -type f -iname '*.srt' -exec bash $0 {} \;
    exit 0
fi

# check if the input file exists
if [[ ! -f "$1" ]]; then
    echo "$1 does not exist"
    exit 1
else
    debug_write "processing $1"
fi

audio_file_without_extension=$(basename "$1" .srt)
audio_file_without_extension="$(dirname "$1")/$audio_file_without_extension"

audio_file=$(get_audio_file "$audio_file_without_extension")

edl_file="${audio_file_without_extension}.edl"

#echo $EDL_HEADER_RECORD > 


convert_srt_to_edl "$1" "$audio_file"

#cat $TMPFILE1 >> "$edl_file"
edl_file="$AUDEY2/edl_file_raw.edl"

if [[ ! -f "$edl_file" ]]; then
    echo $EDL_HEADER_RECORD > "$edl_file"
fi
cat $TMPFILE1 >> "$edl_file"
# get the owner direcory of $1, just one level up, not the full path
owner_dir=$(dirname "$1")
# get the string after the last forward slash
owner_dir=$(basename "$owner_dir")
echo "$owner_dir is the owner directory"
#read -p "Press return to continue"

if [[ ! -f "$AUDEY2/${owner_dir}_raw.edl" ]]; then
  cp -v $TMPFILE1 $AUDEY2/${owner_dir}_raw.edl
else
    cat $TMPFILE1 >> $AUDEY2/${owner_dir}_raw.edl
fi

#cat "$edl_file"