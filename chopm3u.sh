#!/usr/bin/env bash

source $MPVU/util_inc.sh
EDL_HEADER_RECORD="# mpv EDL v0"
# This script reads an m3u file and creates 6 edl files containing random records from the m3u file
# The edl files are named the same as the m3u file but ending with _chopped1.edl, _chopped2.edl, etc
# The edl files are created in the same directory as the $HANDUNI directory
# First, check that the filename is passed as a parameter $1 and it exists
if [[ "$1" == "" ]]; then
    echo "Usage: $0 m3ufile"
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "$1 does not exist"
    exit 1
fi

# create a temporary file to hold the edl records
TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)

# read the m3u file line by line, checking that each record corresponds to a file that exists. Skip any non
# existant files
while read -r pss; do
    if [[ -f "$pss" ]]; then
        echo "$pss" >> $TMPFILE1
    else
        echo "$pss does not exist"
    fi
done < "$1"

#This function does the following
# read through $TMPFILE1. For each file, call get_length to get the length of the file in seconds
# when we write each of the 6 edl files, first add the EDL_HEADER_RECORD
# Calculate a random start time and length for each record, based on the length of the file returned by get_length
# Write the record to the first edl output file.
# repeat the same process for the other 5 edl files, each containing 100 records
# the edl file format is "filename,start,length"
# the start time is in seconds and the length is in seconds
# the start time is a random number between 0 and the length of the file minus 10 seconds
# the length is a random number between 10 and 20 seconds and is less than the length of the file in seconds
# the edl files are written to the $HANDUNI directory

# count the number of records in the m3u file
record_count=$(wc -l < "$TMPFILE1")
total_count=record_count
step_count=1
echo "Number of records in $1: $record_count"

# remove any records from the temporary file that contain a comma or a square bracket
sed -i '/,/d' "$TMPFILE1"
sed -i '/\[/d' "$TMPFILE1"

# this function extracts the file type from the file name in $1
# and checks if the file type is video
# if the file type is video, it returns the length of the video in seconds
# if the file type is not video, it returns 0
get_type() {
   # get the file extension of $1
    file_extension=$(echo "$1" | awk -F. '{print $NF}')
    valid_file_extensions="mp4 mkv avi webm gif avi wmv flv mov"
    for extension in $valid_file_extensions; do
        if [[ "$file_extension" == "$extension" ]]; then
            return 0
        fi
        return 1
    done
}


m3u_record_file=$(basename "$1" .m3u)
counter=0
step_count=0


while read -r file; do
    file_type=$(get_type "$file")
    if [[ $file_type == 0 ]]; then
        echo "Skipping $file "
        continue
    else
        echo "Processing $file"
    fi  
    counter=$((counter+1))
    step_count=$((step_count+1))
    total_length=$(get_length "$file")
    if [[ $total_length -lt 11 ]]; then
        continue
    fi

    if [[ "$total_length" == "" ]]; then
        continue
    fi


    for i in {1..6}; do
        for j in {1..5}; do
            # if the length of the file is less than 10 seconds, skip it
            # check if start_time is a positive integer
            # if [[ $length -lt 9 ]]; then
            #     continue
            # fi
            start_time=$(shuf -i 1-$((total_length-10)) -n 1)
            length=$(shuf -i 10-20 -n 1)

            if [[ $length -lt 10 ]]; then
              continue
            fi
            echo "$file,$start_time,$length" >> "$TMPFILE2"
        done
    done
    # if we have processed 10 records, write a message to the screen. Also calulate the percentage of 
    # records processed and write that to the screen too
    if [[ $counter -eq 10 ]]; then
        echo "$step_count records processed"
        echo "Percentage processed: $(echo "scale=2; $step_count / $record_count * 100" | bc)%"
        counter=0
    fi


done < "$TMPFILE1"
echo "Done"
cat $TMPFILE2 


echo "writing $HANDUNI/$(basename "$1" .m3u)_chopped$i.edl"


for i in {1..6}; do
    
    echo "$EDL_HEADER_RECORD" > "$HANDUNI/$(basename "$1" .m3u)_chopped$i.edl"

    shuf -n 500 "$TMPFILE2" >> "$HANDUNI/$(basename "$1" .m3u)_chopped$i.edl"
done





