#!/usr/bin/env bash

# This script finds image files in specified directories (under $I1 and $I2),
# shuffles them, creates a temporary file list, and launches feh instances
# to display them on the configured screen geometry.
#
# Usage: ./image_screen_filler.sh [GEOMETRY_PREFIX] [SHUFFLE_TIME] [FOLDER_1] [FOLDER_2] ...

# --- Configuration & External Sources ---

# Source utility library for the 'message' function and other shared logic.
source "$MPVU/util_inc.sh" || { echo "Error: Failed to source $MPVU/util_inc.sh"; exit 1; }

# Assumed external variables: $DISPGEO, $I1, $I2, $MPVU, $IMGSRC_ORIGINAL, $ADD_ORIGINAL

# --- Constants (Converted to Arrays for Robust 'find' Argument Passing) ---

# Target file extensions for 'find' (used in primary search)
# The parentheses are included as separate array elements for find's correct logic grouping.
readonly extensions_arr=( \( -iname "*.jpg" -o -iname "*.webm" -o -iname "*.webp" -o -iname "*.png" -o -iname "*.gif" \) )

# Target file extensions for 'find' (used in optional ADD_ORIGINAL search)
readonly original_extensions_arr=( \( -iname "*.jpg" -o -iname "*.webm" -o -iname "*.png" -o -iname "*.gif" \) )


# --- Parameters ---
GEOMETRY_PREFIX=${1:-}           # e.g., "6corners1" or just a screen number '1'
TTIME=${2:-20}                   # Time delay for feh, defaults to 20 seconds
# $3 onwards are treated as the image folder list.

# --- FIX: Handle multiple image folders ($3, $4, ...) or use default list ---
if [[ $# -ge 3 ]]; then
    # Capture all arguments from $3 onwards (e.g., "newmaisey hegre")
    IMAGE_FOLDER_LIST="${@:3}"
else
    # Use the default list if $3 is not provided
    IMAGE_FOLDER_LIST="hegre fehd"
fi
message "Using image folders: $IMAGE_FOLDER_LIST"
# --- END FIX ---

# Override TTIME if FILLET_TIME is set externally (as per old script logic)
if [[ -n "$FILLET_TIME" ]]; then
    TTIME="$FILLET_TIME"
fi

# --- Helper Functions ---

# Search function to consolidate logic
# Dynamically finds the full folder path under the base directory and searches it.
# $1: The root directory to search under ($I1, $I2, or $IMGSRC_ORIGINAL)
# $2: The partial folder name/path to look for (e.g., "fehd" or "fred/wilma")
# $3: A flag (1 or 2) to select the extension array to use.
search_and_shuffle() {
    local base_dir="$1"
    local folder_path="$2"
    local extension_flag="$3"
    local full_path # Variable to hold the found directory path
    local -a extension_list # Array reference to hold the correct extension array
    
    # Select the correct global array based on the flag
    if [[ "$extension_flag" == "1" ]]; then
        extension_list=("${extensions_arr[@]}")
    elif [[ "$extension_flag" == "2" ]]; then
        extension_list=("${original_extensions_arr[@]}")
    fi
    
    # If the array is empty, something is wrong
    if ((${#extension_list[@]} == 0)); then
        echo "Internal Error: Invalid extension flag passed to search_and_shuffle." >&2
        return 1
    fi

    # --- FIX: Use -path matching for flexible sub-directory paths ---
    # 1. We must escape the provided path to prevent wildcards (* or ?) from breaking it.
    # 2. We use '-path' to match the relative path from the root.
    local escaped_path=$(printf '%s' "$folder_path" | sed 's/[][*?.^$]/\\&/g')

    # The search now looks for a directory whose path ENDS with the base_dir + escaped path
    # Example: If base_dir=/home/ben/bikini/images and folder_path=fred/wilma, we search for */fred/wilma
    # We use -type d and limit to the first result found.
    full_path=$(find "$base_dir" -type d -path "*/$escaped_path" 2>/dev/null | head -n 1)

    # --- END FIX ---
    
    if [[ -n "$full_path" && -d "$full_path" ]]; then
        message "Searching folder: $full_path"
        # Use robust array expansion ("${array[@]}") to pass the arguments correctly to find
        find "$full_path" -type f "${extension_list[@]}" | shuf -n 1000 >> "$TMPFILE1"
    else
        # Only show a warning if the folder name was found in *neither* location
        echo "Warning: Image path not found under $base_dir: $folder_path" >&2
    fi
}


# --- Core Logic ---

# 1. Input Validation and Setup

if [[ -z "$GEOMETRY_PREFIX" ]]; then
    echo "Error: Geometry prefix (e.g., '6corners1') is missing." >&2
    exit 1
fi

# Determine the geometry file path
if [[ "$GEOMETRY_PREFIX" =~ ^[0-9]+$ ]]; then
    # If the input is just a number (e.g., '1'), use the generic gN.txt file
    GEOMETRY_FILE="$DISPGEO/g${GEOMETRY_PREFIX}.txt"
else
    # Otherwise, use the full prefix (e.g., '6corners1')
    GEOMETRY_FILE="$DISPGEO/${GEOMETRY_PREFIX}.txt"
fi

if [[ ! -f "$GEOMETRY_FILE" ]]; then
    echo "Error: Geometry file not found: $GEOMETRY_FILE" >&2
    exit 1
fi


# 2. Build the shuffled image list (TMPFILE1)
TMPFILE1=$(mktemp "/tmp/feh_list_XXXXXX.txt")

message "Collecting image files into temporary list: $TMPFILE1"

# --- Search primary libraries ($I1, $I2) using the folder list ---
for folder in $IMAGE_FOLDER_LIST; do
    # Try searching in $I1 (Flag 1 for primary extensions)
    search_and_shuffle "$I1" "$folder" 1
    
    # Try searching in $I2 (Flag 1 for primary extensions)
    search_and_shuffle "$I2" "$folder" 1
done

# --- Optional: Search original library ($IMGSRC_ORIGINAL) ---
if [[ -n "$ADD_ORIGINAL" ]]; then
    message "Adding files from original source directories: $ADD_ORIGINAL"
    for folder in $ADD_ORIGINAL; do
        # Note: We pass Flag 2 for original extensions
        search_and_shuffle "$IMGSRC_ORIGINAL" "$folder" 2
    done
fi

if [[ ! -s "$TMPFILE1" ]]; then
    echo "Error: No images found. Check folder names and paths (\$I1, \$I2, \$IMGSRC_ORIGINAL)." >&2
    rm -f "$TMPFILE1"
    exit 1
fi


# 3. Generate and Run the feh launch script
RUNFEH_SCRIPT=$(mktemp "/tmp/runfeh_XXXXXX.sh")

# Add shebang and cd command
echo "#!/usr/bin/env bash" > "$RUNFEH_SCRIPT"
echo "cd /tmp" >> "$RUNFEH_SCRIPT"

message "Generating feh commands using geometry file: $GEOMETRY_FILE"

# Iterate over geometry file lines and append feh commands to the script
while read -r line; do 
    delay=$(shuf -i 1-"$TTIME" -n 1)
    
    # Append the nohup feh command
    echo "nohup feh -x -B black -r -f $TMPFILE1 -D $delay --scale-down -z -g \"$line\" &" >> "$RUNFEH_SCRIPT"
done < "$GEOMETRY_FILE"

# Make the script executable
chmod +x "$RUNFEH_SCRIPT"

# Execute the feh commands in the background
message "Executing $RUNFEH_SCRIPT..."
nohup bash -x "$RUNFEH_SCRIPT" < /dev/null &

# Note: We rely on the parent process (mpv_blender_feh.sh) or system cleanup for final temp file deletion.