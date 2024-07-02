#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

path="$1"

# Find all video and audio files, ignoring case (e.g., .MP4, .mKV, etc.)
find "$path" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" -o -iname "*.mp3" -o -iname "*.wav" -o -iname "*.m4a" \) | while read file; do

  # Extract base filename without extension
  base=$(basename "$file" | cut -d. -f1)

  # Check if a .srt or .vtt file exists with the same base name
  if [ ! -f "$path/$base.srt" ] && [ ! -f "$path/$base.vtt" ]; then
    echo "$MPVU/whisp_me.sh $file"  # Output the file if no subtitles are found
  fi
done
