#!/usr/bin/env bash
# use nohup mpv --image-display-duration=$DISPLAY_TIME config profiles to cycle imaages
#source $SRC/common_inc.sh
source $MPVU/get_media.sh

echo "In test_get_media"
# get_file_by_type "edl" "mom" 20
# cat $TMPFILE1

SUBJ=$(get_file_by_type "edlblend" "mom" 20)

cat $TMPFILE3

# SUBJ="$(get_file_by_type "edl")"

# shuffle_edl "$SUBJ" 50

# cat $TMPFILE1
#get_file_by_type "edl"