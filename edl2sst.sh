#!/usr/bin/env bash

# this script reads an edl file from $1
# and processes each record one by one, prompting the user for confirmation
# before processing the next record
# the user can also skip a record or quit the script

if [ $# -eq 0 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

#check the edl file exists
if [ ! -f "$1" ]; then
  echo "File $1 does not exist"
  exit 1
fi

echo "Saving PERE: $PERE"

orginal_pere="$PERE"

export PERE=$HOME/bikini/auto_pere

do_sst() {
  echo "Processing $1, $2 $3..."
  # actual processing logic goes here
  # $2 is in seconds. Convert to HH:MM:SS format
    start_time=$(date -u -d @$2 +"%T")
    length_seconds=$3
    echo "Calling SST with $start_time and $length_seconds for $1"
    echo sst \""$1"\" "$start_time" -l "$length_seconds"
    #sst \""$1"\" "$start_time" -l "$length_seconds"
    python $MPVU/shift_subtitles.py "$1" $start_time -l $length_seconds
    # if the return status is an error, print the error and exit the whole script
    if [ $? -ne 0 ]; then
        echo "Error processing $1, $2 $3"
        exit 1
    fi
}

# It then parses the edl records - the format is full_path, start_second, length_seconds.
# It then searches for the corresponding .srt file (same path and name) for the current record
# If the .srt file is found, it displays the record and asks the user to confirm
# If the user confirms, it calls a local function do_sst, passing the current record
# If the user skips, it moves to the next record
# If the user quits, it exits the script

# read the edl file
while IFS=, read -r full_path start_second length_seconds; do
  # ignore records where the first character is #
    if [[ $full_path == \#* ]]; then
        continue
    fi
  # check if the srt file exists
  srt_file="${full_path%.*}.srt"
  if [ -f "$srt_file" ]; then
    echo "Found $srt_file"
    echo "Record: $full_path, $start_second, $length_seconds"
    read -p "Process? (y/n/q): " choice </dev/tty
    case $choice in
      y)
        do_sst "$srt_file" "$start_second" "$length_seconds"
        ;;
      n)
        echo "Skipping..."
        ;;
      q)
        echo "Quitting..."
        exit 0
        ;;
      *)
        echo "Invalid choice. Skipping..."
        ;;
    esac
  else
    echo "No srt file found for $full_path"
  fi
done < "$1"

export PERE=$orginal_pere
echo "PERE: $orginal_pere restored"
