#!/usr/bin/env bash
# This script takes up to two arguments: both a search pattern for $HI/*argument*.edl
# We get two filenames and call random_feh.sh with them.
#

# if $3 is set, use that for VOLUME, otherwise default to 10
if [[ -z "$3" ]]; then
    VOLUME=10
else
    VOLUME="$3"
fi
# if $4 is set, use that for SCREEN_COUNT, otherwise default to 4
if [[ -z "$4" ]]; then
    SCREEN_COUNT=4
else
    SCREEN_COUNT="$4"
fi

echo "Using VOLUME: $VOLUME"
echo "Using SCREEN_COUNT: $SCREEN_COUNT"    


function find_edl_files() {
    local pattern="$1"
    find "$HI" -maxdepth 1 -type f -name "*$pattern*.edl" | shuf -n 1
    if [[ $? -ne 0 ]]; then
        echo "Error finding EDL files with pattern: $pattern"
        exit 1
    fi
}

TEMPFILE=$(mktemp /tmp/split_randoms.XXXXXX)



file1=$(find_edl_files "$1")
EDL1="$file1"
echo "Found EDL file: $file1"
file1="$(basename "$file1")"
file1="${file1%.edl}"  # Remove the .edl extension for consistency)
echo "Trimming EDL file name: $file1"

file2=$(find_edl_files "$2")
EDL2="$file2"
echo "Found EDL file: $file2"
file2="$(basename "$file2")"
file2="${file2%.edl}"  # Remove the .edl extension for consistency)
echo "Trimming EDL file name: $file2"


if [[ -z "$file1" || -z "$file2" ]]; then
    echo "Not enough EDL files found. Please ensure there are at least two matching files."
    exit 1
fi


python3 "$MPVU/interleave_files.py" "$TEMPFILE" "$EDL1" "$EDL2" 
cp $TEMPFILE $HI/latest_split_randoms1.edl -v
echo "Interleaved EDL file1 saved from $TEMPFILE"

cp $TEMPFILE $USCR/split_randoms1_$$.edl -v


python3 "$MPVU/interleave_files.py" "$TEMPFILE" "$EDL2" "$EDL1" 
cp $TEMPFILE $HI/split_randoms2.edl -v
echo "Interleaved EDL file2 saved from $TEMPFILE"

cp $TEMPFILE $USCR/split_randoms2_$$.edl -v

# wait for 2 seconds to ensure the user is happy


# Call random_feh.sh with the two found EDL files
"$MPVU/random_feh.sh" "latest_split_randoms1" 0 $VOLUME $SCREEN_COUNT
"$MPVU/random_feh.sh" "latest_split_randoms2" 2 $VOLUME $SCREEN_COUNT

# propmt the use to press q to quit
echo "Press 'q' to quit the slideshow."
read -r -n 1 -s -p ""  # Wait for a single key
#if the character is q, exit
if [[ $? -eq 0 && $REPLY == "q" ]]; then
    echo "Exiting slideshow."
    pkill -f screen=2
    pkill -f screen=0
fi
