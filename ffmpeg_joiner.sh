#!/usr/bin/env bash
# Input subtitles file
subtitles_file="$1"

TMPFILE1="$(mktemp)"

grep -iw "$2" "$subtitles_file" -B 1 > $TMPFILE1

cat $TMPFILE1 

read -p "$TMPFILE1 press return" 


# this functions takes a full pathname and filename and looks in the same directory
# for an audio file with the same name as the input file, excluding the type of file
# The audio file extensions look up are .mp4 .m4a .mp3 .wav .flac and .webm
# If the audio file is found, the full pathname of the audio file is returned
# If the audio file is not found, the function returns an empty string
find_audio_file() {
    # Input subtitles file
    subtitles_file="$1"
    # get the full pathname of the subtitles_file without an extension
    directory=$(dirname "$subtitles_file")
    audio_file=$(basename -- "$subtitles_file")
    #concatenate the directory and the audio_file
    audio_file="${directory}/${audio_file%.*}"
    # check if the audio file exists with the .m4a or mp3 extension
    if [[ -f "${audio_file}.m4a" ]]; then
        audio_file="${audio_file}.m4a"
    elif [[ -f "${audio_file}.mp3" ]]; then
        audio_file="${audio_file}.mp3"
    elif [[ -f "${audio_file}.mp4" ]]; then
        audio_file="${audio_file}.mp4"
    elif [[ -f "${audio_file}.wav" ]]; then
        audio_file="${audio_file}.wav"
    elif [[ -f "${audio_file}.flac" ]]; then
        audio_file="${audio_file}.flac"
    elif [[ -f "${audio_file}.webm" ]]; then
        audio_file="${audio_file}.webm"
    else
        audio_file=""
    fi
    echo $audio_file
}

# if the subtitles file in $1 does not exist, print an error and exit
if [[ ! -f "$subtitles_file" ]]; then
    echo "Subtitles file $subtitles_file does not exist"
    exit 1
fi

# call find_audio_file and store the resule in a variable called audio_file
find_audio_file "$subtitles_file"
audio_file_extension="${audio_file##*.}"
echo "$audio_file has audio_file_extension is $audio_file_extension"


concatenate_input_files() {
    # Input subtitles file
    subtitles_file="$1"
    # Output directory for ffmpeg input files
    output_dir="/tmp/ffmpeg_inputs"
    # Temporary file for ffmpeg input file paths and timestamps
    # if $output_dir/input_file_list.txt exists, delete it
    if [[ -f "$output_dir/input_file_list.txt" ]]; then
        rm "$output_dir/input_file_list.txt"
    fi
    input_file_list="$output_dir/input_file_list.txt"
    # Output file name
    
    # delete and recreate the $output_dir
    rm -rfi "$output_dir"
    mkdir -p "$output_dir"

    output_file="$output_dir/output.$audio_file_extension"
    cp -v "$audio_file" $output_dir/abc.$audio_file_extension
    
    read -p "press return to continue"

    # Read the subtitles file line by line
    while IFS= read -r line; do
        # Check if the line is a timestamp line
        if [[ $line =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}\ --\>\ [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}$ ]]; then
            # Extract the start and end timestamps
            start_time=$(echo "$line" | awk -F" --> " '{print $1}')
            end_time=$(echo "$line" | awk -F" --> " '{print $2}')
            # replace commas in the start and end times with a period
            start_time=$(echo "$start_time" | tr ',' '.')
            end_time=$(echo "$end_time" | tr ',' '.')
            # Generate the ffmpeg input file name based on the start and end timestamps
            #input_file="$output_dir/input_${start_time}_${end_time}.mp4"
            input_file="$2"
            # Add the input file path and timestamps to the temporary file
            echo "file $input_file" >> $input_file_list
            echo "inpoint $start_time outpoint $end_time" >> $input_file_list
        fi
    done < "$subtitles_file"

    # Use ffmpeg to concatenate the input files
    CURRENT_DIR=$PWD
    cd $output_dir
    ffmpeg -f concat -i "$input_file_list" -c copy "$output_file"
    cd $CURRENT_DIR
}

# Call the function to concatenate the input files
echo "Calling concatenate_files with $subtitles_file and $audio_file"
# get the audio_file extension in a variable

concatenate_input_files $TMPFILE1 "abc.$audio_file_extension"

mpv --volume=100 $output_file