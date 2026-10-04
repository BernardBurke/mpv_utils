#!/usr/bin/env bash
# edl_search.sh - search shorts.edl for keywords, split into AND / OR results
# Usage: ./edl_search.sh keyword1 [keyword2 ...]

SRC="$G2/real/shorts.edl"
AND_OUT="/tmp/short_and.edl"
OR_OUT="/tmp/short_or.edl"

edl_header() {
  if [ -z "$1" ]; then
    echo "Usage: mpv_edl_header <filename>"
    return 1
  fi

  sed -i "1i# mpv EDL v0" "$1"
  echo "Added header to $1"
}

if [ $# -eq 0 ]; then
  echo "Usage: $0 keyword1 [keyword2 ...]" >&2
  exit 1
fi

if [ ! -f "$SRC" ]; then
  echo "Error: $SRC not found in $(pwd)" >&2
  exit 1
fi

# Clean working copy:
#  - drops comment lines (# in column 1), which includes the existing header
#  - keeps only records with exactly 3 comma-separated fields
#    (filename,start,length), so filenames containing commas are excluded
work=$(mktemp)
trap 'rm -f "$work" "$work.new"' EXIT
awk -F, '!/^#/ && NF==3' "$SRC" > "$work"

# --- OR: records containing ANY keyword (case-insensitive, literal match) ---
or_args=()
for kw in "$@"; do
  or_args+=(-e "$kw")
done
grep -iF "${or_args[@]}" "$work" > "$OR_OUT"

# --- AND: records containing ALL keywords (filter repeatedly) ---
cp "$work" "$AND_OUT"
for kw in "$@"; do
  grep -iF -e "$kw" "$AND_OUT" > "$work.new"
  mv "$work.new" "$AND_OUT"
done

# --- Add headers ---
for f in "$AND_OUT" "$OR_OUT"; do
  if [ -s "$f" ]; then
    edl_header "$f"
  else
    echo "No matches for $f, skipping header"
  fi
done

echo "AND records: $(grep -vc '^# mpv EDL v0' "$AND_OUT") -> $AND_OUT"
echo "OR records:  $(grep -vc '^# mpv EDL v0' "$OR_OUT") -> $OR_OUT"
