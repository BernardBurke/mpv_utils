#!/usr/bin/env bash
# use whisper transcribe to make subtitles for a single file
source $SRC/common_inc.sh

if [[ -f "/tmp/whisp_me.killswitch" ]]; then
	echo "Killswitch in place - exitting"
	exit 0
fi

if [[ ! -f "$1" ]]; then
    echo "Please provice an media file that exists"
    exit 1
fi

INPUT_DIR=basename

if [[ "$2" = "" ]]; then
        OUTPUT_DIR=$(dirname "$1")
else
    if [[ -d $2 ]]; then
        OUTPUT_DIR=$2
    else
        echo "$2 is not a valid directory "
        exit 1
    fi
fi

FILE_EXTENSION="${1##*.}"
echo $FILE_EXTENSION

# needs a case statement (mp4 m4a mp3 mkv)
SRT_FILENAME=$OUTPUT_DIR/$(basename "$1" $FILE_EXTENSION)srt
VTT_FILENAME=$OUTPUT_DIR/$(basename "$1" $FILE_EXTENSION)vtt
echo $SRT_FILENAME
echo $VTT_FILENAME

if [[ "$3" = "" ]]; then
        if [[ -f $SRT_FILENAME ]]; then
            echo "$SRT_FILENAME exists and parameter 3 is blank - exiting"
            exit 1
        fi
fi

LNGTH=$(ffprobe -v quiet  -of csv=p=0 -show_entries format=duration "$1")

echo "$1 has a length of $LNGTH"

whisper --output_format srt --language en "$1" --output_dir $OUTPUT_DIR
tt convert -i "$SRT_FILENAME" -o "$VTT_FILENAME"

