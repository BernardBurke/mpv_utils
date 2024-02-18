#!/usr/bin/env bash
# This function will scan a directory and all subdirectories for media files
# Each media files name will be used to look up a .srt or .vtt subtitles file.
# Any media files without a .srt or .vtt file will be printed to the screen
TMPFILE1="$(mktemp)"

does_directory_exit() {
    if [[ -d "$1" ]]; then 
        return 0
    else
        return 1
    fi
}

# This function uses ffprobe to get the length of an audio file
# The second parameter is the minimum length of the audio file
# Files shorter than the minimum length are ignored
# Files as long or longer than the minimum length are returned
get_audio_files() {
        #echo "get_audio_files $1 $2"
        duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1")
        # compare $duration as a floating point number to $2 as an integer number
        if (( $(echo "$duration > $2" |bc -l) )); then
            return 0
        else
            return 1
        fi
 }

get_missing_srt_vtt() {
        find "$1" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.m4a" -o -name "*.mp3" -o -name "*.avi" \) -print0 |
    while IFS= read -r -d '' file; do
        base="${file%.*}"
        if [[ ! -f "$base.srt" && ! -f "$base.vtt" ]]; then
            echo  "$file"
        fi
    done
}

if [[ "$1" == "" ]]; then
    echo "Usage: $0 directory"
    exit 1
fi

#this function takes a temporary file of media files and calls get_audio_files with each filename
lookup_files() {
    while IFS= read -r file; do
        if get_audio_files "$file" 60; then
            echo $MPVU/whisp_me.sh \""$file"\"
        fi  
    done < "$1"
}


if does_directory_exit "$1"; then
        get_missing_srt_vtt "$1" > $TMPFILE1
        lookup_files $TMPFILE1
    else
        echo "Directory $1 does not exist"
        exit 1
fi
