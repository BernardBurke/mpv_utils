#!/usr/bin/env bash
source $MPVU/util_inc.sh
TMPFILE1=$(mktemp)

# if $1 is blank, then exit
if [[ "$1" == "" ]]; then
    message "$1 is blank"
    exit 1
fi


message "Searching for $1 in $GRLSRC and $G2"

find $GRLSRC $G2 -type f -iname '*.srt'  -exec grep -il  "$1" "{}" \;  | grep -v audio | sort -Ru > $TMPFILE1

# this function reads an input file that has one .srt file per line
# Look for the media file that has the same name as the .srt file and
# return the full path to the media file or blank if not found
# make a list of media type types to search for
VIDEO_TYPES="mov mp4 mxf mkv avi mpg m2v m4v ts flv wmv vob webm 3gp ogv mts m2ts mxf m4v dv 3g2 mp3 wav aif aiff flac ogg wma aac ac3 mka mp2 mp1 mpa m4a mpga"
AUDIO_TYPES="mp3 wav aif aiff flac ogg wma aac ac3 mka mp2 mp1 mpa m4a mpga"


function srt_search2media_path {
    local srt_file=$1
    if [[ $2 == "audio" ]]; then
        media_types=$AUDIO_TYPES
    else
        media_types=$VIDEO_TYPES
    fi
    local media_file="${srt_file%.*}"
    media_file="${media_file%/*}/${media_file##*/}"
    for media_type in $media_types; do
        if [[ -f "${media_file}.${media_type}" ]]; then
            echo "${media_file}.${media_type}"
            return
        fi
    done
}

#read $TMPFILE1 and call srt_search2media_path for each line
while read srt_file; do
    srt_search2media_path $srt_file
done < $TMPFILE1


    