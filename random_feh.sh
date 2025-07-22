#!/usr/bin/env bash
# This script gets 2 files from $HI called name_chopped6.edl using find and shuf -n 1
# If a parameter is given, search for files matching *$1*.edl and call gDisplay.sh instead

size_limit=1000

SCREEN=0
VOLUME=20
VIEWPORT_COUNT=1
RUN_COUNT=100
RUN_MODE=edl

# if $1 is given, collect SCREEN, VOLUME and VIEWPORT_COUNT from the command line
if [[ -n "$1" ]]; then
    # SCREEN
    # SCREEN
    if [[ -n "$2" ]]; then
        SCREEN="$2"
    fi

    # VOLUME
    if [[ -n "$3" ]]; then
        VOLUME="$3"
    fi

    # VIEWPORT_COUNT
    if [[ -n "$4" ]]; then
        VIEWPORT_COUNT="$4"
    fi
    echo "Using parameters: SCREEN=$SCREEN, VOLUME=$VOLUME, VIEWPORT_COUNT=$VIEWPORT_COUNT"
else
    echo "No parameters given, using default values: SCREEN=$SCREEN, VOLUME=$VOLUME, VIEWPORT_COUNT=$VIEWPORT_COUNT"
fi

# function that takes SCREEN VOLUME and VIEWPORT_COUNT as parameters - we will use it in the case that $1 is given
gDisplay() {
    local_SCREEN="$2"
    local_VOLUME="$3"
    local_VIEWPORT_COUNT="$4"
    # viewport_count can only be 1 or 4 - otherwise quit
    if [[ "$VIEWPORT_COUNT" -ne 1 && "$VIEWPORT_COUNT" -ne 4 ]]; then
        echo "Error: VIEWPORT_COUNT must be 1 or 4."
        exit 1
    fi
    # get the user to confirm the parameters
    echo "gDisplay parameters:"
    echo "SCREEN: $SCREEN"
    echo "VOLUME: $VOLUME"
    echo "VIEWPORT_COUNT: $VIEWPORT_COUNT"
    # Call gDisplay.sh with the parameters - display the command before calling it
    echo "Calling gDisplay.sh with parameters: $local_VIEWPORT_COUNT $local_VOLUME $local_SCREEN $1"
    # and pause for a moment to let the user see the command
    read -t 2 -p "Pausing for 2 seconds before executing gDisplay.sh..."
    # Assuming gDisplay.sh is in the same directory as this script
    # echo the command to be executed
    echo "$MPVU/gDisplay.sh $local_VIEWPORT_COUNT $local_VOLUME $local_SCREEN $RUN_MODE $RUN_COUNT $1"
    # now execute the command
    "$MPVU/gDisplay.sh" $local_VIEWPORT_COUNT $local_VOLUME $local_SCREEN $RUN_MODE $RUN_COUNT "$1" 
}

if [[ -n "$1" ]]; then
    # Parameter provided: search for files matching *$1*.edl
    FILES=($(find "$HI" -iname "*$1*.edl"))
    if [[ ${#FILES[@]} -lt 1 ]]; then
        echo "Not enough files matching *$1*.edl found."
        exit 1
    fi
    FILE1="${FILES[0]}"
    FILE2="${FILES[1]}"
    echo "Selected files: $FILE1 and $FILE2"
    # Call gDisplay.sh twice
    # chance $FILE1 to just the filename without path or extension
    FILE1=$(basename "$FILE1" .edl)
    gDisplay "$FILE1"  "$SCREEN" "$VOLUME" "$VIEWPORT_COUNT"
    exit 0
fi

# No parameter: original logic
file1_size=0
file2_size=0
while true; do
    FILE1="$(find "$HI" -iname "*_chopped6.edl" | shuf -n 1)"
    file1_size=$(wc -l < "$FILE1")
    echo "Testing file 1: $FILE1 size: $file1_size lines"

    FILE2="$(find "$HI" -iname "*_chopped6.edl" | shuf -n 1)"
    file2_size=$(wc -l < "$FILE2")
    echo "Testing file 2: $FILE2 size: $file2_size lines"

    if [[ $file1_size -le $size_limit && $file2_size -le $size_limit ]]; then
        break
    fi
done

echo "Selected files: $FILE1 and $FILE2 with sizes $file1_size and $file2_size lines respectively."
# now extract the parts of the base filename left of _chopped6
base_name1="${FILE1%_chopped6.edl}"
base_name1=$(basename "$base_name1")
base_name2="${FILE2%_chopped6.edl}"
base_name2=$(basename "$base_name2")
echo "Base names: $base_name1 and $base_name2"

# Now get two folder names from the root of $IMGSRC
FOLDER1="$(find "$IMGSRC" -mindepth 1 -maxdepth 1 -type d | shuf -n 1)"
FOLDER2="$(find "$IMGSRC" -mindepth 1 -maxdepth 1 -type d | shuf -n 1)"
base_imgdir1=$(basename "$FOLDER1")
base_imgdir2=$(basename "$FOLDER2")

echo "Selected folders: $base_imgdir1 and $base_imgdir2"

# and call mpv_feh.sh with the selected files and folders
if [[ -f "$FILE1" && -f "$FILE2" && -d "$FOLDER1" && -d "$FOLDER2" ]]; then
    echo "Calling mpv_feh.sh with:"
    echo "Files: $FILE1, $FILE2"
    echo "Folders: $base_imgdir1, $base_imgdir2"
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    "$MPVU/mpv_feh6.sh" 0 1 "$base_name1" "$base_imgdir1" 2 "$base_name2"
else
    echo "Error: One or more files or folders do not exist."
    exit 1
fi

