#!/usr/bin/env bash
echo "This has been replaced by picker_audio_sub.sh
exit
source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"
# This script takes a search string for $AUDEY/*.srt and one for $HANDUNI/*.edl files
# for every match, the potential files are displayed and the user is asked to choose one srt and one edl files
# The chose files are played with mpv using --sub-file and --audio-file. The audio file
# will have the same name as the srt file but with the extension changed to .mp3, m4a, flac or any other audio extension

# First, check that the search strings are passed as parameters $1 and $2
if [[ "$1" == "" || "$2" == "" ]]; then
    echo "Usage: $0 search_string1 search_string2"
    exit 1
fi

# have $3 be SCREEN $4 be VOLUME $5
if [[ "$3" != "" ]]; then
    SCREEN=$3
else
    SCREEN=2
fi

if [[ "$4" != "" ]]; then
    VOLUME=$4
else
    VOLUME=10
fi

# check that the search strings return at least one file
if [[ $(find $AUDEY $AUDEY2 -name "*$1*" 2>/dev/null | wc -l) -eq 0 ]]; then
    echo "No files found in $AUDEY and $AUDEY2 matching $1"
    exit 1
fi

if [[ $(find $HANDUNI -name "*$2*" 2>/dev/null | wc -l) -eq 0 ]]; then
    echo "No files found in $HANDUNI matching $2"
    exit 1
fi

# create a temporary file to hold the srt records
TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)

# present all the matching srt files and have the use choose one (if there is more than one match)
echo "Choose one of the following srt files:"
srt_files=$(find $AUDEY $AUDEY2 -name "*$1*" 2>/dev/null)
if [[ -z "$srt_files" ]]; then
    echo "No files found in $AUDEY or $AUDEY2 matching $1"
    exit 1
fi
srt_file=$(zenity --file-selection --title="Select an SRT file" --filename="$srt_files")
if [[ -z "$srt_file" ]]; then
    echo "No SRT file selected"
    exit 1
fi
if [[ ! -f "$srt_file" ]]; then
    echo "$srt_file does not exist"
    exit 1
fi

# present all the matching edl files and have the user choose one (if there is more than one match)
echo "Choose one of the following edl files:"
edl_files=$(find $HANDUNI -name "*$2*" 2>/dev/null)
if [[ -z "$edl_files" ]]; then
    echo "No files found in $HANDUNI matching $2"
    exit 1
fi
edl_file=$(zenity --file-selection --title="Select an EDL file" --filename="$edl_files")
if [[ -z "$edl_file" ]]; then
    echo "No EDL file selected"
    exit 1
fi
if [[ ! -f "$edl_file" ]]; then
    echo "$edl_file does not exist"
    exit 1
fi

# get the audio file name from the srt file name
audio_file=$(echo $srt_file | sed 's/\.srt$/.mp3/')
if [[ ! -f "$audio_file" ]]; then
    audio_file=$(echo $srt_file | sed 's/\.srt$/.m4a/')
fi
# also check for wav files
if [[ ! -f "$audio_file" ]]; then
    audio_file=$(echo $srt_file | sed 's/\.srt$/.wav/')
fi

# check that the audio file exists
if [[ ! -f "$audio_file" ]]; then
    echo "$audio_file does not exist"
    exit 1
fi

echo "srt_file: $srt_file"
echo "audio_file: $audio_file"
echo "edl_file: $edl_file"

# play the files with mpv
mpv --sub-file="$srt_file" --fullscreen --fs-screen=$SCREEN \
    --audio-file="$audio_file" --screen=$SCREEN --volume=$VOLUME "$edl_file"





