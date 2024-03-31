#!/usr/bin/env bash

# this script takes two edl files as input
# this first file is read from top to bottom
# one random record is read from the second file
# this random record is inserted between every record of the first file
# the output is written to a temp file and the tmp file is played with mpv
EDL_HEADER_RECORD="# mpv EDL v0"

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <edl1> <edl2>"
    exit 1
fi

# if either input file doesn't exist, exit
if [[ ! -f "$1" ]]; then
    echo "$1 does not exist"
    exit 1
fi

# do the same for the second file
if [[ ! -f "$2" ]]; then
    echo "$2 does not exist"
    exit 1
fi

# use $3 $4 for the screen number and volume
# if they are not set, use the default values
if [[ -z "$3" ]]; then
    screen=1
else
    screen=$3
fi

if [[ -z "$4" ]]; then
    volume=10
else
    screen=$4
fi


# create a temp file
TMPFILE=$(mktemp /tmp/edl.XXXXXXXXXX) || exit 1

# write the EDL_HEADER_RECORD to the temp file
echo $EDL_HEADER_RECORD > $TMPFILE


# read the first file line by line
while read -r pss; do
    # skip files starting with #
    if [[ "$pss" == "#"* ]]; then
        continue
    fi
    # write the record to the temp file
    echo $pss >> $TMPFILE
    # read a random record from the second file
    random_record=$(shuf -n 1 $2)
    # write the random record to the temp file
    echo $random_record >> $TMPFILE

done < "$1"

cat $TMPFILE
#read -p "Press enter to continue"

# play the temp file with mpv

#mpv  --screen=1 --volume=50 "$TMPFILE" --fs-screen=1 --fullscreen
#nohup mpv  --screen=2 --volume=50 "$TMPFILE" --fs-screen=2 --fullscreen &
nohup mpv  --screen=$screen --volume=$volume "$TMPFILE" --fs-screen=1 --fullscreen &

