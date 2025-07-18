#!/usr/bin/env bash
# This script takes one input argument, which is the path to a text file ($PERE_DATA at runtime)
# check if the file exists and is readable
if [[ -f "$1" ]]; then
    DATAFILE="$1" # Use the first argument as the data file path
else
    echo "Usage: $0 <path_to_fred.txt>"
    exit 1
fi

DEFAULTING_EDL_FILE=""

# This function is part of the *generating* script (your main script)
get_afile() {
    local audio_file_path="$1" # Correctly quoted
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
    elif [[ -f "$audio_file_path".aac ]]; then
        audio_file="$audio_file_path".aac
    fi
    echo "$audio_file" # Correctly echoes the result
}

play_a_file() {
    local audio_file="$1"
    if [[ -n "$audio_file" && -f "$audio_file" ]]; then
        echo "Playing audio file: $audio_file"
        # Here you can add your command to play the audio file, e.g., using mpv or another player
        # mpv "$audio_file" &  # Uncomment this line to actually play the audio
    else
        echo "No valid audio file found."
    fi
    if [[ -n "$DEFAULTING_EDL_FILE" ]]; then
      # prompt for a new edl file but use the default if no input is given
        read -p "Enter EDL file path (default: $DEFAULTING_EDL_FILE): " edl_file
        if [[ -z "$edl_file" ]]; then
            edl_file="$DEFAULTING_EDL_FILE"
        fi
        echo "Using default EDL file: $DEFAULTING_EDL_FILE"
    else
        echo "No default EDL file set."
        read -p "Enter EDL file path: " edl_file
        if [[ -z "$edl_file" ]]; then
            echo "No EDL file provided. Exiting."
            exit 1  
    else
            edl_file="$(find "$HI" -iname "$edl_file    " | shuf -n 1)"

            DEFAULTING_EDL_FILE="$edl_file"
        fi
    fi
}

# the main loop reads $DATAFILE and processes each line with     filename="${record%%:*}"
while IFS= read -r record; do
    # Remove part after colon, correctly quoted
    filename="${record%%:*}"
    
    # Get the audio file path using the function
    audio_file=$(get_afile "$filename")
    
    # Check if the audio file exists
    if [[ -n "$audio_file" && -f "$audio_file" ]]; then
        echo "Processing audio file: $audio_file"
        # Here you can add your processing logic for the audio file
    else
        echo "No valid audio file found for: $filename"
    fi
done < "$DATAFILE"

