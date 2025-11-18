#!/usr/bin/env bash

# This script blends two EDL files by interleaving them using a Python script, 
# shakes the two resulting files, and launches two MPV instances on two screens 
# (Screen 0 and Screen 2) using top/bot profiles.
# 
# Usage: ./mpv_blender_feh.sh [VOLUME] [EDL_PARTIAL_1] [EDL_PARTIAL_2] [FOLDER_1] [FOLDER_2] ...

# --- Configuration & External Sources ---

# These variables ($MPVU, $HANDUNI, $HI, $IMGSRC) are assumed to be exported/defined elsewhere.
source "$MPVU/util_inc.sh" || { echo "Error: Failed to source $MPVU/util_inc.sh"; exit 1; }

# --- Constants ---
readonly DEFAULT_VOLUME=10
readonly SCREEN_PRIMARY=0
readonly SCREEN_SECONDARY=2
readonly BLENDED_PREFIX="mpv_blended"
readonly LOG_BASE_PATH="/tmp"

# --- Helper Functions ---

# Function to find the source EDL file using partial matching.
# $1: The partial filename provided by the user (e.g., "my_video").
# $2: The base directory to search in (e.g., $HANDUNI).
get_edl_source_path() {
    local partial_name="$1"
    local search_dir="$2"
    
    # Use globbing for partial matching (e.g., "$HANDUNI/*my_video*.edl")
    local matches=("$search_dir"/*"$partial_name"*.edl)

    if ((${#matches[@]} == 0)) || [[ ! -f "${matches[0]}" ]]; then
        echo "" # No match found
        return
    fi
    
    # Pick one at random if multiple matches are found.
    if ((${#matches[@]} > 1)); then
        local random_index=$((RANDOM % ${#matches[@]}))
        echo "${matches[$random_index]}"
    else
        echo "${matches[0]}"
    fi
}

# Function to interleave two source EDL files using Python, create four shaken 
# copies (two for screen 0 and two for screen 2), and clean up the temporary blend file.
create_and_shake_blended_edls() {
    local source_file_1="$1"
    local source_file_2="$2"
    local temp_file  # Variable to hold the unique temporary file path
    
    # 1. Create a secure, unique temporary file path within $HI
    temp_file=$(mktemp "$HI/${BLENDED_PREFIX}_XXXXXX.edl")
    
    message "Blending via interleaving: $(basename "$source_file_1") and $(basename "$source_file_2")"
    
    # List of files to create and shake (Index indicates screen/slot)
    local dest_files=(
        "$HANDUNI/${BLENDED_PREFIX}_S${SCREEN_PRIMARY}_top.edl"
        "$HANDUNI/${BLENDED_PREFIX}_S${SCREEN_PRIMARY}_bot.edl"
        "$HANDUNI/${BLENDED_PREFIX}_S${SCREEN_SECONDARY}_top.edl"
        "$HANDUNI/${BLENDED_PREFIX}_S${SCREEN_SECONDARY}_bot.edl"
    )

    # --- ORDER 1 (A, B, A, B, ...) - Used for Screen 0 Top and Screen 2 Top ---
    message "Creating Order 1 Interleave (A, B, ...)"
    python3 "$MPVU/interleave_files.py" "$temp_file" "$source_file_1" "$source_file_2" || {
        echo "Error: Failed to interleave files (Order 1, 2). Ensure python3 and script are available."
        rm -f "$temp_file" 
        return 1
    }
    
    # Copy/Shake for Screen 0 Top and Screen 2 Top
    cp -f -v "$temp_file" "${dest_files[0]}" 
    "$MPVU/shake.sh" "${dest_files[0]}" > /dev/null 2>&1 || echo "Warning: shake.sh failed for ${dest_files[0]}."
    
    cp -f -v "$temp_file" "${dest_files[2]}" 
    "$MPVU/shake.sh" "${dest_files[2]}" > /dev/null 2>&1 || echo "Warning: shake.sh failed for ${dest_files[2]}."


    # --- ORDER 2 (B, A, B, A, ...) - Used for Screen 0 Bot and Screen 2 Bot ---
    message "Creating Order 2 Interleave (B, A, ...)"
    python3 "$MPVU/interleave_files.py" "$temp_file" "$source_file_2" "$source_file_1" || {
        echo "Error: Failed to interleave files (Order 2, 1). Ensure python3 and script are available."
        rm -f "$temp_file" 
        return 1
    }
    
    # Copy/Shake for Screen 0 Bot and Screen 2 Bot
    cp -f -v "$temp_file" "${dest_files[1]}" 
    "$MPVU/shake.sh" "${dest_files[1]}" > /dev/null 2>&1 || echo "Warning: shake.sh failed for ${dest_files[1]}."

    cp -f -v "$temp_file" "${dest_files[3]}" 
    "$MPVU/shake.sh" "${dest_files[3]}" > /dev/null 2>&1 || echo "Warning: shake.sh failed for ${dest_files[3]}."

    # 3. Clean up the temporary file
    rm -f "$temp_file"
    message "Blended files prepared for screens $SCREEN_PRIMARY and $SCREEN_SECONDARY."
    return 0
}


# Function to launch the two mpv instances and image_screen_filler on the specified screen.
# $1: The screen number (0 or 2)
# $2... : The list of image directory paths (e.g., "fred", "wilma", "fred/barney")
run_mpv_pair() {
    # VOLUME is sourced from the global scope of the main script logic
    local screen_num="$1"
    
    # Use shift to remove $1 (screen_num), leaving only the folder paths in $@
    shift
    
    message "Launching MPV pair on screen $screen_num..."

    local edl_path_top="$HANDUNI/${BLENDED_PREFIX}_S${screen_num}_top.edl"
    local edl_path_bot="$HANDUNI/${BLENDED_PREFIX}_S${screen_num}_bot.edl"
    
    local log_file_top="$LOG_BASE_PATH/VIDEO1_S${screen_num}.log"
    local log_file_bot="$LOG_BASE_PATH/VIDEO2_S${screen_num}.log"
    
    # --- Top MPV instance ---
    # Redirect stdin from /dev/null to prevent blocking the parent shell.
    nohup mpv \
        --volume="$VOLUME" \
        --screen="$screen_num" \
        --profile=topmid \
        --log-file="$log_file_top" \
        "$edl_path_top" < /dev/null &
        
    # --- Bottom MPV instance ---
    # Redirect stdin from /dev/null to prevent blocking the parent shell.
    nohup mpv \
        --volume="$VOLUME" \
        --screen="$screen_num" \
        --profile=botmid \
        --log-file="$log_file_bot" \
        "$edl_path_bot" < /dev/null &
        
    # --- Run the image script ---
    # The image path arguments are now contained in $@ (all remaining arguments).
    # We pass them UNQUOTED using "$@", ensuring each path is a separate argument.
    if [[ "$#" -gt 0 ]]; then
        message "Running image filler script on screen $screen_num with paths: $@"
        
        # CORRECTLY calling image_screen_filler.sh
        # Call: image_screen_filler.sh [GEOMETRY_PREFIX] [SHUFFLE_TIME] [FOLDER_1] [FOLDER_2] ...
#        nohup "$MPVU/image_screen_filler.sh" "6corners$screen_num" 10 "$@" < /dev/null &
        "$MPVU/image_screen_filler.sh" "g6corners$screen_num" 10 "$@"  
    fi
}


# --- Main Script Logic ---

# 1. Parameter Initialization
VOLUME=${1:-$DEFAULT_VOLUME}
EDL_PARTIAL_1=$2 # No default, must be provided
EDL_PARTIAL_2=$3 # No default, must be provided

# --- Capture all arguments from $4 onwards into a robust array ---
# IMG_FOLDER_PATHS is an array containing all image path/folder arguments
IMG_FOLDER_PATHS=("${@:4}") 

if ((${#IMG_FOLDER_PATHS[@]} > 0)); then
    message "Image folder list provided: ${IMG_FOLDER_PATHS[*]}"
fi
# --- END FIX ---


message "--- Blended MPV Launcher (FEH) ---"
message "Volume: $VOLUME | EDL 1: '$EDL_PARTIAL_1' | EDL 2: '$EDL_PARTIAL_2'"

# 2. Source File Validation and Preparation

EDL_SOURCE_1=$(get_edl_source_path "$EDL_PARTIAL_1" "$HANDUNI")
# Check if EDL_PARTIAL_1 was provided and a file was found
if [[ -z "$EDL_PARTIAL_1" ]]; then
    echo "Error: Primary EDL partial name (\$2) is missing. Please provide a search term."
    exit 1
elif [[ -z "$EDL_SOURCE_1" ]]; then
    echo "Error: No primary EDL file found for partial name '$EDL_PARTIAL_1' in $HANDUNI"
    exit 1
fi

EDL_SOURCE_2=$(get_edl_source_path "$EDL_PARTIAL_2" "$HANDUNI")
# Check if EDL_PARTIAL_2 was provided and a file was found
if [[ -z "$EDL_PARTIAL_2" ]]; then
    echo "Error: Secondary EDL partial name (\$3) is missing. Please provide a search term."
    exit 1
elif [[ -z "$EDL_SOURCE_2" ]]; then
    echo "Error: No secondary EDL file found for partial name '$EDL_PARTIAL_2' in $HANDUNI"
    exit 1
fi


# 3. Create the four shaken, blended EDL files
if ! create_and_shake_blended_edls "$EDL_SOURCE_1" "$EDL_SOURCE_2"; then
    echo "Script execution aborted due to EDL preparation failure."
    exit 1
fi

# 4. Execution on Screen 0 and Screen 2
# We pass the array elements UNQUOTED so they arrive as separate arguments.
run_mpv_pair "$SCREEN_PRIMARY" "${IMG_FOLDER_PATHS[@]}"
run_mpv_pair "$SCREEN_SECONDARY" "${IMG_FOLDER_PATHS[@]}"

message "MPV instances launched on screens $SCREEN_PRIMARY and $SCREEN_SECONDARY. Type 'q' to kill them."

# 5. Cleanup/Exit Prompt
echo "---"
read -r -p "Press **Return** to leave processes running, or press **q** and **Return** to kill processes: " ANS

if [[ "$ANS" == "q" ]]; then
    message "Killing running MPV and image processes..."
    # Kill using the profile names and feh (if used by image_screen_filler.sh)
    pkill feh & 
    pkill -f topmid
    pkill -f botmid
    message "Cleanup complete."
else
    message "Exiting parent script. MPV processes are running in the background."
fi