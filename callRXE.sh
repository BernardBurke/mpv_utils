#!/usr/bin/env bash
echo "this has been replaced by picker_audio_sub.sh
exit
source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"
# This script searches the contents of all .srts in $AUDEY and $AUDEY2 for a string
# provided in $1. It is a standard grep search string. The script then searches for
# the same string in all .edl files in $HANDUNI and $HANDUNI2. If there are matches
# display the filename that matched and the text that matched including 2 lines before and afterwards.
# The user is then asked to choose one of the srt files using zenity

# First, check that the search string is passed as a parameter
if [[ "$1" == "" ]]; then
    echo "Usage: $0 search_string"
    exit 1
fi

# have $2 be SCREEN $3 be VOLUME $4
if [[ "$2" != "" ]]; then
    SCREEN=$2
else
    SCREEN=2
fi

if [[ "$3" != "" ]]; then
    VOLUME=$3
else
    VOLUME=10
fi

# check that the search strings return at least one file
if [[ $(find $AUDEY -name "*.srt" 2>/dev/null | wc -l) -eq 0 && $(find $AUDEY2 -name "*.srt" 2>/dev/null | wc -l) -eq 0 ]]; then
    echo "No files found in $AUDEY and $AUDEY2 matching $1"
    exit 1
fi

# Now display the filenames matched and the text that matched
echo "Searching for $1 in $AUDEY and $AUDEY2"
grep -H -C 2 -i "$1" $AUDEY/*.srt $AUDEY2/*.srt

# Now prompt the user for part of a filename and use zenity to select the specific file
echo "Choose one of the following srt files:"
srt_files=$(find $AUDEY -name "*.srt" 2>/dev/null)
srt_files2=$(find $AUDEY2 -name "*.srt" 2>/dev/null)
if [[ -z "$srt_files" && -z "$srt_files2" ]]; then
    echo "No files found in $AUDEY and $AUDEY2 matching $1"
    exit 1
fi
srt_file=$(zenity --file-selection --title="Select an SRT file" --filename="$srt_files $srt_files2")
if [[ -z "$srt_file" ]]; then
    echo "No SRT file selected"
    exit 1
fi
if [[ ! -f "$srt_file" ]]; then
    echo "$srt_file does not exist"
    exit 1
fi
# now repeat the process for an edl file in $HANDUNI 
echo "Searching for $2 in $HANDUNI"
grep -H -C 2 -i "$2" $HANDUNI/*.edl
# Now prompt the user for part of a filename and use zenity to select the specific file
echo "Choose one of the following edl files:"
edl_files=$(find $HANDUNI -name "*.edl" 2>/dev/null)
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
# Now call $MPVU/rxe.sh with the srt and edl files and SCREEN and VOLUME
$MPVU/rxe.sh $srt_file $edl_file $SCREEN $VOLUME
exit 0


