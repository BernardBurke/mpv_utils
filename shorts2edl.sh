#!/usr/bin/env bash
source "$MPVU/util_inc.sh"
EDL_HEADER_RECORD="# mpv EDL v0"
JOBS=$(nproc)

# Usage: script directory|listfile [screen] [volume]
#  - directory: scans for videos, writes <directory>/shorts.edl
#  - file:      reads one video path per line, writes /tmp/shorts.edl
# Existing output is used as a cache: only new/modified files are probed.

if [[ -z "$1" ]]; then
    echo "Usage: $0 directory"
    exit 1
fi

if [[ -f "$1" ]]; then
    MODE=file
    OUTPUT_FILE="/tmp/shorts.edl"
elif [[ -d "$1" ]]; then
    MODE=dir
    OUTPUT_FILE="$1/shorts.edl"
else
    echo "$1 does not exist"
    exit 1
fi

# (unused in this script, kept from the original)
SCREEN=${2:-2}
VOLUME=${3:-10}

# --- 1. Build the list of files to include ---
FILES=()
if [[ $MODE == file ]]; then
    echo "Processing file $1"
    while IFS= read -r file; do
        [[ -z "${file//[[:space:]]/}" ]] && continue
        if [[ -f "$file" ]]; then
            FILES+=("$file")
        else
            echo "Skipping invalid file: $file"
        fi
    done < "$1"
else
    while IFS= read -r -d '' file; do
        FILES+=("$file")
    done < <(find "$1" -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.webm" \
                -o -iname "*.mkv" -o -iname "*.gif" \) -print0 | sort -z)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No files to process."
    exit 1
fi

# --- 2. Load the existing EDL into memory (path -> length) ---
declare -A CACHE

# Parse "path, start, length" from the right, so commas inside paths are OK
load_record() {
    local line=$1 len rest path
    [[ $line == \#* || $line != *", "*", "* ]] && return
    len=${line##*, }
    rest=${line%, *}
    path=${rest%, *}
    CACHE["$path"]=$len
}

if [[ -f "$OUTPUT_FILE" ]]; then
    while IFS= read -r line; do
        load_record "$line"
    done < "$OUTPUT_FILE"
fi

# --- 3. Work out which files need probing ---
# Missing from the cache, or modified since the EDL was last written
MISSES=()
for f in "${FILES[@]}"; do
    if [[ -z ${CACHE["$f"]+x} || ( -f "$OUTPUT_FILE" && "$f" -nt "$OUTPUT_FILE" ) ]]; then
        MISSES+=("$f")
    fi
done
echo "${#FILES[@]} files: $(( ${#FILES[@]} - ${#MISSES[@]} )) cached, ${#MISSES[@]} to probe"

# --- 4. Probe only the misses, in parallel ---
if [[ ${#MISSES[@]} -gt 0 ]]; then
    NEWRECS=$(mktemp)
    TMP_OUT=""
    trap 'rm -f "$NEWRECS" "$TMP_OUT"' EXIT

    export -f get_length
    printf '%s\0' "${MISSES[@]}" |
        xargs -0 -n1 -P "$JOBS" bash -c \
            'printf "%s, 0, %s\n" "$1" "$(get_length "$1")"' _ > "$NEWRECS"

    while IFS= read -r line; do
        load_record "$line"
    done < "$NEWRECS"
fi

# --- 5. Write the EDL atomically, preserving the file order ---
TMP_OUT=$(mktemp "${OUTPUT_FILE}.XXXXXX")
trap 'rm -f "$NEWRECS" "$TMP_OUT"' EXIT

{
    echo "$EDL_HEADER_RECORD"
    for f in "${FILES[@]}"; do
        if [[ -n ${CACHE["$f"]} ]]; then
            printf '%s, 0, %s\n' "$f" "${CACHE["$f"]}"
        else
            echo "Warning: no length for $f, skipped" >&2
        fi
    done
} > "$TMP_OUT"

chmod 644 "$TMP_OUT"
mv "$TMP_OUT" "$OUTPUT_FILE"
echo "EDL written to $OUTPUT_FILE"
