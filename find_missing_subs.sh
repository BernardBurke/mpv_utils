#!/bin/bash

# Usage: find_missing_subs.sh /path/to/videos

if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

VIDEO_EXTENSIONS=("mp4" "mkv" "avi" "webm" "wav" "wmv" )

find "$1" -type f | while read -r filepath; do
    ext="${filepath##*.}"
    ext_lower="${ext,,}"
    
    # Check if it's a video file
    for vid_ext in "${VIDEO_EXTENSIONS[@]}"; do
        if [[ "$ext_lower" == "$vid_ext" ]]; then
            # Strip extension and look for matching .srt or .vtt
            base="${filepath%.*}"
            if [[ ! -f "${base}.srt" && ! -f "${base}.vtt" ]]; then
                echo "$filepath"
            fi
            break
        fi
    done
done
