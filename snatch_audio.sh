#!/bin/bash
# use FFMpeg to copy out the audio stream from a video file
source $MPVU/util_inc.sh

TMPFILE1=$(mktemp)


if [[ "$1" == "" ]]; then
    message "Please specify youtube/rumble url"
    exit 1
fi 

if yt-dlp -f mp4-240p "$1"; then
    message "Downloaded $1"
else
    message "Download failed - probably an unsupported video format"
fi

BARE_NAME="$TMPFILE1"
DIRNAME="$(dirname "$TMPFILE1")"
BASE_NAME=$(basename -- "$TMPFILE1")
FILE_EXTENSION="${BASE_NAME##*.}"
FILE_NAME="${BASE_NAME%.*}"
#ALPH_NAME="${FILE_NAME//[^[:alnum:]_-]/}" 
OUTFILENAME=$(echo $FILE_NAME | sed "s/\[.*$//g" | sed -r "s/\(.*$//g" | sed "s/\./ /g" | sed "s/  / /g")
OUTFILENAME=$(echo $FILE_NAME | sed 's/[^a-zA-Z0-9_-]//')
OUTFILENAME=$(echo $FILE_NAME | sed 's/[^[:alnum:]\ ]//g' | tr -s " ")
TARGET_NAME="$DIRNAME/$OUTFILENAME.$FILE_EXTENSION"

if [[ "$1" != "$TARGET_NAME" ]]; then
    message "$BARE_NAME contains unfriendly characters and will be renamed to $TARGET_NAME"
    read -p "Press enter to continue"
    mv "$1" "$TARGET_NAME"
fi

AUDIO_FORMAT="$(ffprobe -v quiet -of csv=p=0 -select_streams a:0 -show_entries stream=codec_name "$TARGET_NAME")"
TARGET_AUDIO="$DIRNAME/$OUTFILENAME.$AUDIO_FORMAT"
message "AudioFormat: $AUDIO_FORMAT target filename: $TARGET_AUDIO"

ffmpeg -i "$BARE_NAME" -vn -acodec copy "$TARGET_AUDIO"
message "Audio produced: $AUDIO_FORMAT target filename: $TARGET_AUDIO