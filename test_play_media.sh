#!/bin/bash
# Need a simple way to test changes
# source $SRC/common_inc.sh
source $MPVU/play_media.sh
source $MPVU/util_inc.sh

# IMGSUBTITLES="$(random_subtitles)"
# echo $IMGSUBTITLES

if [[ $1 == "" ]]; then
    VOLUME=20
else
    VOLUME=$1
fi 

if [[ $2 == "" ]]; then
    SCREEN=0
else
    SCREEN=$2
fi 


if [[ $3 == "" ]]; then
    SEARCH_STRING=a
else
    SEARCH_STRING="$3"
fi 



TESTSRT="$(get_random_subtitles "$SEARCH_STRING")"

echo "SRT file is $TESTSRT "

#get__subtitle_related_media "$TESTSRT"

TEST_RELMEDIA="$(get__subtitle_related_media "$TESTSRT")"

echo "Related media file is $TEST_RELMEDIA"

# TESTES="$(get_random_video)"
TESTES="$(get_random_edl_content "$SEARCH_STRING")"

TMPFILE1="$(mktemp)"

shuffle_edl "$TESTES"

TESTES=$TMPFILE1
echo "random video file is $TESTES"



IS_PLAYLIST=false

play_1_subs "$TESTES" "$TESTSRT" $VOLUME $SCREEN

exit 1

if minimum_length "$TESTES" "$1"; then
    mpv "$TESTES" 
else
    echo "Too short"
fi 
# $echo $TESTES 
# grep "$1" "$TESTES"

echo $TESTES 
#grep "$1" "$TESTES"


