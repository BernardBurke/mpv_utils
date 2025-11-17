#!/usr/bin/env bash

# This script runs MPV instances on specified screens with .edl files and optionally displays images.
# It supports single-file mode, split-screen mode, and multi-screen looping.

# --- Configuration & External Sources ---

# Use 'source' to ensure these are available. Assuming your common_inc.sh is no longer needed.
# The user-defined variables $MPVU, $HANDUNI, $HI, $IMGSRC are assumed to be exported/defined elsewhere.
source "$MPVU/util_inc.sh" || { echo "Error: Failed to source $MPVU/util_inc.sh"; exit 1; }

# --- Constants ---
readonly DEFAULT_SCREEN=1
readonly DEFAULT_VOLUME=10
readonly DEFAULT_EDL_PARTIAL="last_week"
readonly EDL_DEST_PREFIX="mpv_feh6"
readonly SPLIT_DEST_PREFIX="mpv_split6"
readonly LOG_BASE_PATH="/tmp"

# --- Helper Functions ---

# Function to find the source EDL file using partial matching.
# $1: The partial filename provided by the user (e.g., "last_week").
# $2: The base directory to search in (e.g., $HANDUNI).
# Returns a single full path, or an empty string if none found.
get_edl_source_path() {
    local partial_name="$1"
    local search_dir="$2"
    
    # Use globbing for partial matching (e.g., "$HANDUNI/*last_week*.edl")
    # This captures all matches into an array.
    local matches=("$search_dir"/*"$partial_name"*.edl)

    if ((${#matches[@]} == 0)) || [[ ! -f "${matches[0]}" ]]; then
        echo "" # No match found
        return
    fi
    
    # As requested: "pic one at random"
    if ((${#matches[@]} > 1)); then
        # Pick one at random
        local random_index=$((RANDOM % ${#matches[@]}))
        echo "${matches[$random_index]}"
    else
        # Only one match found
        echo "${matches[0]}"
    fi
}

# Function to copy the source EDL file 6 times and shake them.
# $1: Source EDL file path (full path).
# $2: Destination prefix (e.g., "mpv_feh6" or "mpv_split6").
# Note: This function replaces the old 'save_6' logic.
copy_and_shake_edls() {
    local source_file="$1"
    local dest_prefix="$2"
    local dest_dir="$HANDUNI"
    
    message "Preparing EDL files from: $(basename "$source_file")"
    
    # 1. Clear stale files with the destination prefix
    # The old logic removed ALL files matching a pattern, which could be risky.
    # Let's trust that 'cp' will overwrite correctly, but ensure old 'split6' files are gone.
    if [[ "$dest_prefix" == "$SPLIT_DEST_PREFIX" ]]; then
        message "Checking for and removing stale split files."
        rm -f "$dest_dir"/"$dest_prefix"*.edl
    fi

    # 2. Copy and shake 6 times
    for i in {1..6}; do
        local dest_name="$dest_dir/${dest_prefix}${i}.edl"
        
        # Use 'cp' with -f to force overwrite, and -v for visual feedback.
        cp -f -v "$source_file" "$dest_name" || { message "Error copying $source_file to $dest_name"; return 1; }
        
        # Assume shake.sh is robust
        "$MPVU/shake.sh" "$dest_name" || { message "Warning: shake.sh failed for $dest_name"; }
    done
    
    message "Successfully prepared 6 files with prefix '$dest_prefix'."
    return 0
}

# Function to launch the two mpv instances and fillet_screens
# $1: The screen number (e.g., 0, 1, 2)
# $2: The base EDL index for the pair (e.g., 1 for the first pair, 3 for the second)
# $3: The EDL file prefix to use (e.g., "mpv_feh6" or "mpv_split6")
# $4: The image directory (can be empty string)
run_mpv_pair() {
    local screen_num="$1"
    local base_index="$2"
    local edl_prefix="$3"
    local img_dir="$4"
    
    message "Launching MPV pair for screen $screen_num, indices $base_index and $((base_index + 1))"

    local edl_path_top="$HANDUNI/${edl_prefix}${base_index}.edl"
    local edl_path_bot="$HANDUNI/${edl_prefix}$((base_index + 1)).edl"
    
    local log_file_top="$LOG_BASE_PATH/VIDEO1_S${screen_num}.log"
    local log_file_bot="$LOG_BASE_PATH/VIDEO2_S${screen_num}.log"
    
    # Top MPV instance
    nohup mpv \
        --volume="$VOLUME" \
        --screen="$screen_num" \
        --profile=topmid \
        --log-file="$log_file_top" \
        "$edl_path_top" &
        
    # Bottom MPV instance
    nohup mpv \
        --volume="$VOLUME" \
        --screen="$screen_num" \
        --profile=botmid \
        --log-file="$log_file_bot" \
        "$edl_path_bot" &
        
    # Run the image script
    sleep 1
    nohup "$IMGSRC/fillet_screens.sh" "6corners$screen_num" 10 "$img_dir" < /dev/null & # <-- ADDED
}

# --- Main Script Logic ---

# 1. Parameter Initialization (More Robust)
SCREEN=${1:-$DEFAULT_SCREEN}          # $1: Screen number
VOLUME=${2:-$DEFAULT_VOLUME}          # $2: Volume level
EDL_PARTIAL_MAIN=${3:-$DEFAULT_EDL_PARTIAL} # $3: Main EDL partial name (e.g., "last_week")
IMGDIR=${4:-}                        # $4: Image directory (optional)
ONE_SCREEN=${5:-}                    # $5: Screen mode ('', '2', or loop count)
EDL_PARTIAL_SPLIT=${6:-}             # $6: Split EDL partial name (optional)

message "--- Initialization ---"
message "Starting on screen $SCREEN at volume $VOLUME."
message "Main EDL Partial: '$EDL_PARTIAL_MAIN'"
message "Image Directory: '$IMGDIR'"
message "Screen Mode: '$ONE_SCREEN' (Empty=Single, '2'=Dual, Number=Loop)"
message "Split EDL Partial: '$EDL_PARTIAL_SPLIT'"

message "Cleaning up stale EDL files..."

rm -fv "$HANDUNI/mpv_feh6?.edl"
rm -fv "$HANDUNI/mpv_split6?.edl"

read -r -p "Press **Return** to continue, or **Ctrl-C** to abort: " ANS

# 2. Source File Validation and Preparation

# --- Main EDL File (Mandatory) ---
MAIN_EDL_SOURCE=$(get_edl_source_path "$EDL_PARTIAL_MAIN" "$HANDUNI")

if [[ -z "$MAIN_EDL_SOURCE" ]]; then
    echo "Error: No main EDL file found for partial name '$EDL_PARTIAL_MAIN' in $HANDUNI"
    exit 1
fi

if ! copy_and_shake_edls "$MAIN_EDL_SOURCE" "$EDL_DEST_PREFIX"; then
    echo "Error preparing main EDL files."
    exit 1
fi

# --- Split EDL File (Optional) ---
SPLIT_SCREEN_MODE=false
if [[ -n "$EDL_PARTIAL_SPLIT" ]]; then
    message "Split screen mode requested for partial name: '$EDL_PARTIAL_SPLIT'"
    SPLIT_EDL_SOURCE=$(get_edl_source_path "$EDL_PARTIAL_SPLIT" "$HANDUNI")
    
    if [[ -z "$SPLIT_EDL_SOURCE" ]]; then
        echo "Error: No split EDL file found for partial name '$EDL_PARTIAL_SPLIT' in $HANDUNI"
        exit 1
    fi
    
    if ! copy_and_shake_edls "$SPLIT_EDL_SOURCE" "$SPLIT_DEST_PREFIX"; then
        echo "Error preparing split EDL files."
        exit 1
    fi
    SPLIT_SCREEN_MODE=true
fi

# --- Image Directory Validation (Optional) ---
if [[ -n "$IMGDIR" ]]; then
    FULL_IMG_PATH="$IMGSRC/$IMGDIR"
    if [[ ! -d "$FULL_IMG_PATH" ]]; then
        echo "Error: No valid image directory found at $FULL_IMG_PATH"
        exit 1
    fi
    #IMGDIR="$FULL_IMG_PATH" # Use the full path for consistency
    message "Using images from $IMGDIR"
    if [[ "$IMGDIR" == "" ]]; then
        echo "Error: IMGDIR cannot be an empty string if specified."
        exit 1
    fi
fi




# 3. Execution based on ONE_SCREEN mode
message "--- Execution ---"

# Determine which EDL prefix to use for the top instance
# The bottom instance always uses $EDL_DEST_PREFIX (mpv_feh6)
TOP_EDL_PREFIX="$EDL_DEST_PREFIX"
if $SPLIT_SCREEN_MODE; then
    message "Running in **split screen mode**: Top MPV will use '$SPLIT_DEST_PREFIX' files."
    TOP_EDL_PREFIX="$SPLIT_DEST_PREFIX"
fi

if [[ -z "$ONE_SCREEN" ]]; then
    # Single Screen Mode (Default)
    message "**Single Screen Mode**: Launching on screen $SCREEN."
    
    # Run: Top uses index 1, Bottom uses index 2
    run_mpv_pair "$SCREEN" 1 "$TOP_EDL_PREFIX" "$IMGDIR"

elif [[ "$ONE_SCREEN" == "2" ]]; then
    # Dual Screen Mode
    message "**Dual Screen Mode**: Launching on screens 0 and 2."
    
    # Screen 0: Top uses index 1, Bottom uses index 2
    run_mpv_pair 0 1 "$TOP_EDL_PREFIX" "$IMGDIR"
    
    # Screen 2: Top uses index 3, Bottom uses index 4
    run_mpv_pair 2 3 "$TOP_EDL_PREFIX" "$IMGDIR"

else
    # Loop Through Screens Mode
    
    # We rely on ONE_SCREEN being a number greater than 0, defaulting to $SCREEN if not provided as '2' or empty.
    # The original script used $SCREEN for LOOPCNT, and iterated from 0 up to $LOOPCNT.
    # We will preserve the original logic's intent (iterate $SCREEN + 1 times, from screen 0 up to $SCREEN).
    LOOPCNT="$SCREEN"
    message "**Loop Screen Mode**: Launching $LOOPCNT + 1 pairs on screens 0 through $LOOPCNT."
    
    local k=1 # EDL file index (starts at 1)
    for ((j=0; j <= LOOPCNT; j++)); do
        # j is the screen number (0, 1, 2, ...)
        # k is the base EDL index (1, 3, 5, ...)
        run_mpv_pair "$j" "$k" "$TOP_EDL_PREFIX" "$IMGDIR"
        
        # Increment k by 2 for the next screen pair (e.g., 1->3, 3->5)
        k=$((k + 2))
    done
fi


# 4. Cleanup/Exit Prompt
# Use 'wait' to ensure the mpv processes are registered before prompting.
# wait
echo "---"
read -r -p "Press **Return** to continue, or press **q** and **Return** to kill processes: " ANS

if [[ "$ANS" == "q" ]]; then
    message "Killing running processes..."
    # The original script targeted feh and MPV profiles
    pkill feh & # Assuming feh is started by fillet_screens.sh
    pkill -f topmid
    pkill -f botmid
    message "Cleanup complete."
else
    message "Exiting without killing running MPV processes."
fi