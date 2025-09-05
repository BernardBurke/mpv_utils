#!/bin/bash

# A simple script to play all media files in the current directory with mpv,
# then prompt for a new filename.

# Set the Internal Field Separator to handle filenames with spaces
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Check if mpv is installed
if ! command -v mpv &> /dev/null
then
    echo "mpv could not be found. Please install it to use this script."
    exit 1
fi

echo "Starting interactive file rename script."
echo "Press 'q' to stop mpv playback and proceed with the rename prompt."
echo "Press 'Ctrl+C' to exit the script at any time."
echo "---------------------------------------------------------------"

# Define the list of file extensions you want to process
file_extensions=("mp3" "m4a" "mp4" "mkv" "webm" "ogg" "wav" "flac" "mov" "avi")

# Use a flag to track if any files were found
files_found=false

# Loop through each file extension
for ext in "${file_extensions[@]}"; do
    # Loop through all files matching the current extension
    for file in *.$ext; do
        # Check if a file was found (in case there are no files with that extension)
        if [ ! -f "$file" ]; then
            continue
        fi

        files_found=true

        echo ""
        echo "Now playing: '$file'"
        
        # Play the file with mpv.
        # It's smart enough to know whether to show video or just play audio.
        mpv --fullscreen "$file"

        # Prompt the user for a new filename
        read -p "Enter new filename (or just press Enter to keep '$file'): " -e -i "$file" new_name

        # Check if the user entered a new filename
        if [[ "$new_name" != "$file" ]]; then
            # Check if the new name is not empty
            if [[ -n "$new_name" ]]; then
                # Use 'mv' to rename the file
                mv -v "$file" "$new_name"
            else
                echo "Skipping rename. New name was empty."
            fi
        else
            echo "No change. Filename will remain '$file'."
        fi

        echo "---------------------------------------------------------------"
    done
done

# Check if the loop processed any files
if ! $files_found; then
    echo "No media files found with the specified extensions."
fi

# Restore the original IFS
IFS=$SAVEIFS

echo "Script finished."