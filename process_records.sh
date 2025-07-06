#!/bin/bash

# Check if Zenity is installed
if ! command -v zenity &> /dev/null
then
    echo "Zenity is not installed. Please install it using: sudo apt install zenity"
    exit 1
fi

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <text_file> <edl_filename_part>"
    exit 1
fi

TEXT_FILE="$1"
EDL_FILENAME_PART="$2"
PROCESSED_COUNT=0

DEFAULT_EDL_FOLDER="$HI"

# --- Find and select EDL file ---
echo "Searching for EDL files matching '*${EDL_FILENAME_PART}*.edl'..."
mapfile -t matching_edl_files < <(find $DEFAULT_EDL_FOLDER -maxdepth 1 -type f -name "*${EDL_FILENAME_PART}*.edl" -print0 | xargs -0 -n1 basename | sort)

EDL_FILE=""
NUM_MATCHES=${#matching_edl_files[@]}

if [ "$NUM_MATCHES" -eq 0 ]; then
    zenity --error --text="No EDL files found matching '*${EDL_FILENAME_PART}*.edl' in the current directory. Please ensure the file exists."
    exit 1
elif [ "$NUM_MATCHES" -eq 1 ]; then
    EDL_FILE="${matching_edl_files[0]}"
    zenity --info --text="Found one EDL file: ${EDL_FILE}"
else
    echo "Multiple EDL files found. Please select one using Zenity."
    # Prepare list for Zenity: "Column1" "Item1" "Column2" "Item2" ...
    zenity_list_items=""
    for edl in "${matching_edl_files[@]}"; do
        zenity_list_items+="FALSE \"$edl\" " # Start with FALSE for radio buttons
    done

    EDL_FILE=$(zenity --list \
        --title="Select EDL File" \
        --text="Multiple EDL files found. Please select one:" \
        --column="Select" --column="Filename" \
        --radiolist \
        ${zenity_list_items} \
        2>/dev/null) # Suppress stderr messages from zenity

    if [ -z "$EDL_FILE" ]; then
        zenity --warning --text="No EDL file selected. Exiting."
        exit 1
    fi
    zenity --info --text="You selected: ${EDL_FILE}"
fi

echo "Using EDL file: ${EDL_FILE}"

# --- Process each record in the text file ---
if [ ! -f "$TEXT_FILE" ]; then
    zenity --error --text="Text file not found: ${TEXT_FILE}"
    exit 1
fi

echo "Reading records from ${TEXT_FILE}..."

while IFS= read -r record; do
    PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
    echo "--- Processing Record ${PROCESSED_COUNT} ---"
    echo "Current record: $record"

    # Ask user for confirmation
    if zenity --question --title="Confirm Record" --text="Do you want to use this record?\n\nRecord: ${record}"; then
        echo "User confirmed using record: $record"

        # --- CUSTOMIZE YOUR CALL HERE ---
        # Now you have:
        # $record   - The current line from your text file
        # $EDL_FILE - The selected (or uniquely found) EDL file
        #
        # Replace the echo command below with your actual kokoro command.
        # Example:
        # /path/to/kokoro_script.py --text "$record" --edl "$EDL_FILE" --output "output_${PROCESSED_COUNT}.wav"
        #
        # For demonstration, we'll just print them:
        echo "Simulating call with Record: \"$record\" and EDL File: \"$EDL_FILE\""
        $MPVU/play_audio_with_edl.sh "$record" "$HI/$EDL_FILE" 1 90 
        # Example kokoro command placeholder:
        # python3 -m kokoro --text "$record" --voice af_heart --output_path "output_audio/${PROCESSED_COUNT}_$(basename "${EDL_FILE%.*}")_audio.wav"
        # Or if you have a specific kokoro command that uses an EDL:
        # your_kokoro_command --input_text "$record" --edl_path "$EDL_FILE" --output_prefix "output_${PROCESSED_COUNT}"

        # You might want to add error checking for your kokoro command here
        # if [ $? -ne 0 ]; then
        #     zenity --error --text="Kokoro command failed for record: $record"
        # fi

    else
        echo "User skipped record: $record"
        zenity --info --title="Skipped" --text="Record skipped: ${record}"
    fi
    echo "" # Newline for better readability in terminal
done < "$TEXT_FILE"

echo "Script finished processing ${PROCESSED_COUNT} records."
