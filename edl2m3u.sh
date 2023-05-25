#!/bin/bash
# read an edl and output the unique files as a m3u style playlist
source $SRC/common_inc.sh
source $MPVU/util_inc.sh 

SCRATCH_DIR="$(mktemp -d)"

if [[ "$1" == "" ]]; then
    message "Please specify an edl file"
    exit 1
fi

if [[ ! -f "$1" ]]; then
        message "Please provice an edl file that exists"
        exit 1
fi 


while IFS=, read -r fname start end; do
    echo "$fname" >> $TMPFILE1
done < $1

cat $TMPFILE1 | sort -Ru | grep -v "#"

