#!/usr/bin/env bash
# use whisper transcribe to make subtitles for a single file
#source $SRC/common_inc.sh

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

# whisper --output_format srt --language en "$1" --output_dir $OUTPUT_DIR
# whisper --output_format srt --language en --model large-v3  "$1" --output_dir $OUTPUT_DIR
#whisper --output_format srt --language en --model large-v3  --word_timestamps True --max_line_width 80 "$1" --output_dir $OUTPUT_DIR
#whisper --output_format srt --language en  --model large-v3  --word_timestamps True --max_line_width 80 "$1" --output_dir $OUTPUT_DIR
# took out the model large-v3 as it was not working with the latest version of whisper (slow
whisper --output_format srt --language en  --word_timestamps True --max_line_width 80 "$1" --output_dir $OUTPUT_DIR
ffmpeg -i "$SRT_FILENAME" "$VTT_FILENAME"



#   --word_timestamps WORD_TIMESTAMPS
#                         (experimental) extract word-level timestamps and refine the results based on them (default: False)
#   --prepend_punctuations PREPEND_PUNCTUATIONS
#                         if word_timestamps is True, merge these punctuation symbols with the next word (default: "'“¿([{-)
#   --append_punctuations APPEND_PUNCTUATIONS
#                         if word_timestamps is True, merge these punctuation symbols with the previous word (default:
#                         "'.。,，!！?？:：”)]}、)
#   --highlight_words HIGHLIGHT_WORDS
#                         (requires --word_timestamps True) underline each word as it is spoken in srt and vtt (default: False)
#   --max_line_width MAX_LINE_WIDTH
#                         (requires --word_timestamps True) the maximum number of characters in a line before breaking the line
#                         (default: None)
#   --max_line_count MAX_LINE_COUNT
#                         (requires --word_timestamps True) the maximum number of lines in a segment (default: None)
#   --max_words_per_line MAX_WORDS_PER_LINE
#                         (requires --word_timestamps True, no effect with --max_line_width) the maximum number of words in a segment
#                         (default: None)
