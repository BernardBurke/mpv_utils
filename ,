#!/bin/bash

# Check if a filename argument was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "Error: File '$1' not found."
  exit 1
fi

# Read the file line by line
while IFS=: read -r srt_filespec rest; do
  # Extract the directory and filename from the srt filespec
  srt_dir=$(dirname "$srt_filespec")
  srt_filename=$(basename "$srt_filespec")

  # Extract the filename without extension
  filename_no_ext="${srt_filename%.*}"

  # Find the video file in the same directory
  for video_ext in avi mp4 mkv mov; do
    video_file="${srt_dir}/${filename_no_ext}.${video_ext}"
    if [ -f "$video_file" ]; then
      echo "$video_file"
      break
    fi
  done
done < "$1"
