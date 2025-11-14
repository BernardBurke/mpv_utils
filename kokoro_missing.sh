#!/usr/bin/env bash

# if KOKORO_ONNX is not set, complain and exit
if [[ -z "$KOKORO_ONNX" ]]; then
  echo "Error: KOKORO_ONNX environment variable is not set."
  exit 1
fi

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


if [[ ! -d "$path" && ! -f "$path" ]]; then
  echo "Error: $path is not a valid file or directory."
  exit 1
fi


echo "KOKORO_ONNX is set to: $KOKORO_ONNX path provided: $path"

if [[ -d "$KOKORO_ONNX" ]]; then
  echo "Using KOKORO_ONNX directory: $KOKORO_ONNX"
else
  echo "Error: KOKORO_ONNX directory not found."
  exit 1
fi

# Find all video and audio files, ignoring case (e.g., .MP4, .mKV, etc.)
counter=0
tempfile="$(mktemp)"



if [[ -f "$path" ]]; then
  cp "$path" "$tempfile"
else
  find "$path" -type f -iname '*.txt'  > "$tempfile"
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
  if [[ ! -f "$lpath/$base.m4a" && ! -f "$lpath/$base.mp3" ]]; then
    echo "python3 $KOKORO_ONNX/kokoro_tts_file.py  \"$file\""  # Output the file if no subtitles are found
  fi
done < "$tempfile"
