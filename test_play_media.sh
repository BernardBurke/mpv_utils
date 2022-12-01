#!/bin/bash
# Need a simple way to test changes
# source $SRC/common_inc.sh
# source $MPVU/play_media.sh
source $MPVU/util_inc.sh

# IMGSUBTITLES="$(random_subtitles)"
# echo $IMGSUBTITLES






TESTES="$(get_random_video)"

if minimum_length "$TESTES" "$1"; then
    mpv "$TESTES" 
else
    echo "Too short"
fi 
# $echo $TESTES 
# grep "$1" "$TESTES"

echo $TESTES 
#grep "$1" "$TESTES"


