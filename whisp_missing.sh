#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi


if [[ $2 == "" ]]; then
  loop_count=1
else
  loop_count=$2
fi

path="$1"


# Find all video and audio files, ignoring case (e.g., .MP4, .mKV, etc.)
counter=0
tempfile="$(mktemp)"

if [[ -f "$path" ]]; then
  cp "$path" "$tempfile"
else
  find "$path" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" -o -iname "*.mp3" -o -iname "*.wav" -o -iname "*.m4a" \)  > "$tempfile"
fi

while read file; do
  counter=$((counter + 1))
  if [ $counter -gt $loop_count ]; then
    break
  fi
  # Extract base filename without extension
  base=$(basename "$file" | cut -d. -f1)

  lpath="$(dirname "$file")"
  # Check if a .srt or .vtt file exists with the same base name
  if [ ! -f "$lpath/$base.srt" ] && [ ! -f "$lpath/$base.vtt" ]; then
    echo "$MPVU/whisp_me.sh \"$file\""  # Output the file if no subtitles are found
  fi
done < "$tempfile"
