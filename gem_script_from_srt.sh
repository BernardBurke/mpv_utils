#!/bin/bash

# --- GLOBAL VARIABLES (or variables set by your environment) ---
# Ensure these are set before running the script or adjust their sourcing.
# For demonstration, I'll put placeholders. In your real script, they might come from .bashrc, etc.
#HI="/path/to/high/importance/folder" # This path should be correctly set
#MPVU="/path/to/mpvu/scripts"        # This path should be correctly set
#LME="/path/to/lme/scripts"          # This path should be correctly set (used in your original example's last line)


# --- FUNCTION DEFINITION ---
# This function is part of the *generating* script (your main script)
get_afile() {
    local audio_file_path="$1" # Correctly quoted
    local audio_file=""
    if [[ -f "$audio_file_path".m4a ]]; then
        audio_file="$audio_file_path".m4a
    elif [[ -f "$audio_file_path".mp3 ]]; then
        audio_file="$audio_file_path".mp3
    elif [[ -f "$audio_file_path".wav ]]; then
        audio_file="$audio_file_path".wav
    elif [[ -f "$audio_file_path".flac ]]; then
        audio_file="$audio_file_path".flac
    elif [[ -f "$audio_file_path".mpga ]]; then
        audio_file="$audio_file_path".mpga
    elif [[ -f "$audio_file_path".aac ]]; then
        audio_file="$audio_file_path".aac
    fi
    echo "$audio_file" # Correctly echoes the result
}


# --- MAIN LOOP ---
# The outer loop reads `fred.txt`
# It then *generates* script content to stdout for each record.
# This content will then be executed by the receiving `bash` shell.

# Start a placeholder for your Fred.txt file
FRED_TXT_PATH="fred.txt" # Make sure fred.txt exists and has content

# You can omit the 'done <' if you manually provide input later
while IFS= read -r record; do
    # --- Step 1: Process the current 'record' from fred.txt ---
    # These variables (`filename`, `directory`, `filestub`, `parpar`, `audio`)
    # are for *this iteration* of the outer loop.
    # They are then passed *into* the generated script's content.

    # Remove part after colon, correctly quoted
    filename="${record%%:*}"

    # Basic file existence check (optional for generated output, but good for parent script)
    if [[ ! -f "$filename" ]]; then
        echo "echo \"Warning: Skipping record '$record' - file not found: '$filename'\"" >&2
        # Use >&2 to send warnings to stderr so they don't pollute the generated script output
        continue # Skip to the next record in fred.txt
    fi

    # Extract directory, correctly quoted
    directory="$(dirname "$filename")"

    # Extract basename, then remove .srt extension, correctly quoted
    filestub="$(basename "$filename")"
    filestub="${filestub%.srt}"

    # Rebuild parpar, correctly quoted
    parpar="${directory}/${filestub}"

    # Call get_afile function to find the actual audio file
    audio="$(get_afile "$parpar")"

    # Check if get_afile found an audio file for this record
    if [ -z "$audio" ]; then
        echo "echo \"Warning: Skipping record '$record' - no audio file found for base path: '$parpar'\"" >&2
        continue # Skip to the next record
    fi

    # --- Step 2: Start the Heredoc to write the *runtime script* content to stdout ---
    # We are using `cat << EOF_SCRIPT` without quotes around EOF_SCRIPT
    # This means variables from the *outer* script ($HI, $MPVU, $audio, $edlname)
    # will be expanded *here* (when the heredoc is processed by the outer script).
    # Variables that should expand *later* (like $ANS) or commands that should run later
    # need to be escaped.

    # Each `echo` statement inside the loop outputs a line of the *generated* script.
    # We use `cat` here just for clear heredoc syntax.
    # The output of this `cat` command goes to stdout.

    cat << EOF_SCRIPT
# Generated script content for record: "$record"

# Prompt for filename part (HI is already expanded by the outer script)
echo "Give me part of a filename in '$HI'"

# Read user input
read -p "Filename: " ANS

# Find the EDL filename (HI is outer, ANS expands here for the inner script)
# Need to escape the $(), and the "$" for ANS.
# Note the double quotes around "$HI" in find for spaces.
edlname="\$(find "$HI" -iname "*\$ANS*.edl" | shuf -n 1)"

# Basic check for edlname
if [ -z "\$edlname" ]; then
    echo "Warning: No EDL file found matching '\$ANS' in '$HI'. Skipping this step."
    # We don't exit 1 here, as the user might want to continue the overall process.
    # If this is critical, you might want to exit the sub-script.
fi

# Execute the play_audio_with_edl.sh script (MPVU is expanded by outer script)
# audio is also expanded by outer script, edlname will be from the inner script's find
"$MPVU/play_audio_with_edl.sh" "$audio" "\$edlname" 1 90

# Prompt to continue
read -p "Press return to continue" dummy_variable

EOF_SCRIPT

    # Add a separator if you want visually distinct script blocks in stdout
    # echo "### END_RECORD_SCRIPT ###"

done < bikini/repere/love.you.dad.data # Correctly quote FRED_TXT_PATH
